require 'quality-measure-engine'
require 'health-data-standards'
namespace :cypress do

  task :setup => :environment

  desc 'Perform all tasks necessary for initializing a newly installed system'
  task :initialize => :setup do
    # Only use one of the initialize commands so we don't accidentally double evaluate all of the measures
    task("measures:download").invoke unless @local_installation
    task("measures:install").invoke
    task("mpl:initialize").invoke
  end
  
  desc "Delete all collections from the database related to the Cypress workflow (e.g. vendors, products, etc)"
  task :reset => :setup do
    Mongoid.default_session.database.drop()
  end


  desc "Download the set of valuesets required by the installed measures"
  task :cache_valuesets, [:username, :password] => :setup do |t,args|


    oids = YAML.load(File.open("config/oids.yml"))
    valuesets = oids || []
    valuesets.concat Measure.all.collect {|m| m.oids}

    valuesets.flatten!
    valuesets.compact!
    valuesets.uniq!
    NLM_CONFIG = APP_CONFIG["nlm"]
    

    # make sure the directory is there if we are to store the valueset files there
    if NLM_CONFIG["output_dir"]
          FileUtils.mkdir_p(NLM_CONFIG["output_dir"])
    end

    errors = {}
    api = HealthDataStandards::Util::VSApi.new(NLM_CONFIG["ticket_url"],NLM_CONFIG["api_url"],args[:username],args[:password])
    RestClient.proxy = ENV["http_proxy"]
    valuesets.each_with_index do |oid,index| 
      begin
        vs_data = api.get_valueset(oid) 
        vs_data.force_encoding("utf-8") # there are some funky unicodes coming out of the vs response that are not in ASCII as the string reports to be
       
        # only store on the file system if the directory is configured
        if NLM_CONFIG["output_dir"]
          File.open(File.join(NLM_CONFIG["output_dir"], "#{oid.downcase}.xml"), "w") do |f|
            f.puts vs_data
          end
        end

        doc = Nokogiri::XML(vs_data)
        doc.root.add_namespace_definition("vs","urn:ihe:iti:svs:2008")
        vs_element = doc.at_xpath("/vs:RetrieveValueSetResponse/vs:ValueSet")
        if vs_element && vs_element["ID"] == oid
          
          vs = HealthDataStandards::SVS::ValueSet.load_from_xml(doc)
          # look to see if there is a valueset with the given oid and version already in the db
          old = HealthDataStandards::SVS::ValueSet.where({:oid=>vs.oid, :version=>vs.version}).first
          if !old 
           vs.save!
          end
        else
          errors[oid] = "Not Found"
        end
      rescue 
        errors[oid] = $!
        
      end
      print "\r"
      print "#{index+1} of #{valuesets.length} processed : error downloading #{errors.keys.length} valuesets"
      STDOUT.flush
    end

    if !errors.empty?
      File.open("oid_errors.txt", "w") do |f|
        f.puts errors.keys.join("\n") 
      end
      puts ""
      puts "There were errors retreiveing #{errors.keys.length} valuesets. Cypress May not work correctly without thses valusets installed."
      puts "A list of the valueset OIDs that were unable to be retrieved have been written to the file oid_errors.txt"
   end
  end

  desc "Process a schematron file and place the results in the output directory for the listed phases "
  task :process_schematron, [:schematron_file,:output_dir,:phases] => :setup do |t,args|
    xslt = Nokogiri::XSLT(File.new("./resources/schematron/iso-schematron-xslt1/iso_svrl_for_xslt1.xsl"))
    phases = (args["phases"] || "#ALL").split
    schematron_file = args["schematron_file"]
    output_dir = args["output_dir"]
    files = File.directory?(schematron_file) ? Dir.glob("#{schematron_file}/*.sch") : schematron_file;
    
    files.each do |f|
      doc = Nokogiri::XML(File.new(f))
      base = File.basename(f,".sch")
      phases.each do |phase|
       fname = phase=="#ALL" ? "#{base}.xslt" : "#{base}_#{phase}.xslt"
       doc.root["defaultPhase"] = phase
       File.open(File.join(output_dir,fname),"w") do |f|
         f.puts xslt.transform(doc)
       end
      end
    end
  end
end