module Cypress
  class ValuesetUpdater

    attr_reader :options, :nlm_config
    attr_accessor :api

    def initialize(options)
      @options = options
      @nlm_config = APP_CONFIG["nlm"]
      @api = HealthDataStandards::Util::VSApi.new(nlm_config["ticket_url"],nlm_config["api_url"],options[:username],options[:password])
      # make sure the directory is there if we are to store the valueset files there
      if nlm_config["output_dir"]
        FileUtils.mkdir_p(nlm_config["output_dir"])
        @output = true
      end
    end


    def perform
     if options[:clear]
        HealthDataStandards::SVS::ValueSet.all.delete()
      end

      status_reporter = options[:logger] || STDOUTReporter.new

      valuesets = get_deduped_valuesets

      status_reporter.total_length = valuesets.length

      errors = {}
      get_proxy_ticket

      valuesets.each_with_index do |oid,index|
        begin

          doc = get_document(oid)

          doc.root.add_namespace_definition("vs","urn:ihe:iti:svs:2008")
          vs_element = doc.at_xpath("/vs:RetrieveValueSetResponse/vs:ValueSet")

          if vs_element && vs_element["ID"] == oid
            vs_element["id"] = oid

            store_vs(oid, doc) if nlm_config["output_dir"]

            vs = HealthDataStandards::SVS::ValueSet.load_from_xml(doc)

            vs.save! if vs_not_in_db(vs)

          else
            status_reporter.log(:error, " #{oid} NOT FOUND")
          end
        rescue
          status_reporter.log(:error, "#{oid} - #{$!.message}")
        end
        status_reporter.processed(oid)

      end
        status_reporter.finished
    end

    def vs_not_in_db(vs)
      # look to see if there is a valueset with the given oid and version already in the db
      HealthDataStandards::SVS::ValueSet.where({:oid=>vs.oid, :version=>vs.version}).first.nil?
    end

    def store_vs(oid, doc)
      File.open(File.join(nlm_config["output_dir"], "#{oid.downcase}.xml"), "w") do |f|
        f.puts doc.to_s
      end
    end

    def get_proxy_ticket
      RestClient.proxy = @options[:http_proxy] || ENV["http_proxy"]
      @api.get_proxy_ticket
    end

    def get_document(oid)
      # there are some funky unicodes coming out of the vs response
      # that are not in ASCII as the string reports to be
      vs_data = @api.get_valueset(oid).force_encoding("utf-8")

      Nokogiri::XML(vs_data)
    end

    def get_deduped_valuesets
      Measure.all.collect {|m| m.oids}.flatten.compact.uniq
    end
  end

  class STDOUTReporter
    attr_accessor :messages
    attr_accessor :total_length
    attr_accessor :processed_oids

    def initialize()
      @messages = {:error=>[], :info=>[]}
      @processed_oids = []
    end

    def log(type, message)
       messages[type] ||= []
       messages[type] << message
    end

    def finished
      errors = messages[:error]
      if !errors.empty?
        File.open("oid_errors.txt", "w") do |f|
          f.puts errors.to_yaml
        end
        puts ""
        puts "There were errors retreiveing #{errors.length} valuesets. Cypress May not work correctly without thses valusets installed."
        puts "A list of the valueset OIDs that were unable to be retrieved have been written to the file oid_errors.txt"
      end
    end

    def processed(oid)
      errors = messages[:error]
      processed_oids << oid
      print "\r"
      print "#{processed_oids.length} of #{total_length} processed : error downloading #{errors.length} valuesets"
      STDOUT.flush
    end

    def percentage_complete
      processed_oids.length / total_length
    end

  end

end
