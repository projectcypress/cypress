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
    valuesets = Measure.all.collect {|m| m.oids}
    valuesets.flatten!
    valuesets.compact!
    valuesets.uniq!
    NLM_CONFIG = APP_CONFIG["nlm"]
    
    api = HealthDataStandards::Util::VSApi.new(NLM_CONFIG["ticket_url"],NLM_CONFIG["api_url"],args[:username],args[:password])
    RestClient.proxy = ENV["http_proxy"]
    api.process_valuesets(valuesets) do |oid,vs_data| 
      begin
        vs_data.force_encoding("utf-8")
        File.open(File.join("./temp", "#{oid.downcase}.xml"), "w") do |f|
          f.puts vs_data
        end

        doc = Nokogiri::XML(vs_data)
        doc.root.add_namespace_definition("vs","urn:ihe:iti:svs:2008")
        vs_element = doc.at_xpath("/vs:RetrieveValueSetResponse/vs:ValueSet")
        if vs_element && vs_element["ID"] == oid
          puts "#{oid} Found"
          vs = HealthDataStandards::SVS::ValueSet.load_from_xml(doc)
          # look to see if there is a valueset with the given oid and version already in the db
          old = HealthDataStandards::SVS::ValueSet.where({:oid=>vs.oid, :version=>vs.version}).first
          if !old 
           vs.save!
          end
        else
          puts "#{oid} -- Not Found"
        end
      rescue 

        puts "#{oid} #{$!.message} "
      end
    end

  end
end