require 'quality-measure-engine'
require 'health-data-standards'
namespace :cypress do

  task :setup => :environment

  
  desc "Delete all collections from the database related to the Cypress workflow (e.g. vendors, products, etc)"
  task :reset => :setup do
    Mongoid.default_session.database.drop()
  end


  desc "Download the set of valuesets required by the installed measures"
  task :cache_valuesets, [:username, :password, :clear] => :setup do |t,args|

    job = Cypress::ValuesetUpdater.new({:username=>args.username, 
                                          :password=>args.password,
                                          :clear=>args.clear})
    job.perform

  end


  desc "extract oids from valueset file names" 
  task :extract_oids, [:dir,:out_file] => :setup do |t,args|

    oids = []
    Dir.glob(args[:dir]).each do |f|
      oids << File.basename(f,".xml")
    end

    File.open("config/oids.yml","w") do |f|
      f.puts oids.to_yaml
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

  task :create_admin_account, [:username,:password]=> :setup do |t,args| 
    admin_account = User.new(
                     :first_name =>     "Administrator",
                     :last_name =>      "Administrator",
                     :email =>          args.username,
                     :password =>       args.password,
                     :agree_license =>  true,
                     :admin =>          true,
                     :approved =>       true)
    admin_account.save!
  end


end



