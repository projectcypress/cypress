module Cypress
	class ValuesetUpdateJob

		attr_reader :options

		def initialize(options)
		  @options = options
		end

		def before(job, args)
			@job = job
		end

		def perform
	   if options[:clear]
	      HealthDataStandards::SVS::ValueSet.all.delete()
	    end

	    status_reporter = options[:status_reporter] || STDOUTReporter.new
	   
	    valuesets =  Measure.all.collect {|m| m.oids}

	    valuesets.flatten!
	    valuesets.compact!
	    valuesets.uniq!

	    status_reporter.total_length = valuesets.length
	    
	    nlm_config = APP_CONFIG["nlm"]
	    

	    # make sure the directory is there if we are to store the valueset files there
	    if nlm_config["output_dir"]
	          FileUtils.mkdir_p(nlm_config["output_dir"])
	    end

	    errors = {}
	    api = HealthDataStandards::Util::VSApi.new(nlm_config["ticket_url"],nlm_config["api_url"],options[:username],options[:password])
	    RestClient.proxy = options[:http_proxy] || ENV["http_proxy"]
	    valuesets.each_with_index do |oid,index| 
	      begin

	        vs_data = api.get_valueset(oid) 
	        vs_data.force_encoding("utf-8") # there are some funky unicodes coming out of the vs response that are not in ASCII as the string reports to be
	        doc = Nokogiri::XML(vs_data)

	        doc.root.add_namespace_definition("vs","urn:ihe:iti:svs:2008")
	        vs_element = doc.at_xpath("/vs:RetrieveValueSetResponse/vs:ValueSet")
	        
	        if vs_element && vs_element["ID"] == oid
	        vs_element["id"] = oid
	        # only store on the file system if the directory is configured
		        if nlm_config["output_dir"]
		          File.open(File.join(nlm_config["output_dir"], "#{oid.downcase}.xml"), "w") do |f|
		            f.puts doc.to_s
		          end
		        end

	          vs = HealthDataStandards::SVS::ValueSet.load_from_xml(doc)
	          # look to see if there is a valueset with the given oid and version already in the db
	          old = HealthDataStandards::SVS::ValueSet.where({:oid=>vs.oid, :version=>vs.version}).first
	          if old.nil?
	           vs.save!
	          end
	        else
	          status_reporter.error(oid,"NOT FOUND")
	        end
	      rescue 
	        status_reporter.error(oid, $!.message)
	      end
	      status_reporter.processed(oid)
	      
	    end
	    	status_reporter.finished
		end
	end

	class STDOUTReporter
		attr_accessor :errors
		attr_accessor :total_length
		attr_accessor :processed_oids

	 	def initialize()
	 		@errors = {}
	 		@processed_oids = []
	 	end

		def error(oid, message)
			errors[oid] = message
		end

		def finished
		 	if !errors.empty?
	      File.open("oid_errors.txt", "w") do |f|
	        f.puts errors.to_yaml
	      end
	      puts ""
	      puts "There were errors retreiveing #{errors.keys.length} valuesets. Cypress May not work correctly without thses valusets installed."
	      puts "A list of the valueset OIDs that were unable to be retrieved have been written to the file oid_errors.txt"
   		end
		end

		def processed(oid)
			processed_oids << oid
			print "\r"
      print "#{processed_oids.length} of #{total_length} processed : error downloading #{errors.keys.length} valuesets"
      STDOUT.flush
		end

		def percentage_complete
			processed_oids.length / total_length
		end

	end

end