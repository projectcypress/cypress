require 'quality-measure-engine'
require 'health-data-standards'
require 'fileutils'
require 'open-uri'
require 'highline/import'
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
    files = File.directory?(schematron_file) ? Dir.glob("#{schematron_file}/*.sch") : [schematron_file];
    
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

  desc %{ 
    Create an admin account.  The admin account can do admin
      like things
  }
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


  task :set_admin, [:user_email]=> :setup do |t,args| 
    admin_account = User.where({:email => args.user_email}).first
    admin_account[:admin] = true          
    admin_account.save!
  end


  desc %{ Download measure/test deck bundle. 
    options
    nlm_user    - the nlm username to authenticate to the server - will prompt is not supplied
    nlm_passwd  - the nlm password for authenticating to the server - will prompt if not supplied 
    version     - the version of the bundle to download. This will default to the version 
                  declared in the config/cypress.yml file or to the latest version if one does not exist there"

   example usage:
    rake cypress:bundle_download nlm_name=username nlm_passwd=password version=2.1.0-latest                  
  }
  task :download_bundle => :setup do
    nlm_user = ENV["nlm_user"]
    nlm_passwd = ENV["nlm_pass"]
    measures_dir = File.join(Rails.root, "bundles")

    while nlm_user.nil? || nlm_user == ""
      nlm_user = ask("NLM Username?: "){ |q| q.readline = true }
    end

    while nlm_passwd.nil? || nlm_passwd == ""
      nlm_passwd = ask("NLM Password?: "){ |q| q.echo = false
                                               q.readline = true }
    end

    bundle_version = ENV["version"] || APP_CONFIG["default_bundle"] || "latest"
    @bundle_name = "bundle-#{bundle_version}.zip"
    
    puts "Downloading and saving #{@bundle_name} to #{measures_dir}"
    # Pull down the list of bundles and download the version we're looking for
    bundle_uri = "http://demo.projectcypress.org/bundles/#{@bundle_name}"
    bundle = nil

    tries = 0
    max_tries = 10
    last_error = nil
    while bundle.nil? && tries < max_tries do
      tries = tries + 1
      begin
        bundle = open(bundle_uri, :proxy => ENV["http_proxy"],:http_basic_authentication=>[nlm_user, nlm_passwd] )
      rescue OpenURI::HTTPError => oe
        last_error = oe
        if oe.message == "401 Unauthorized"
          puts "Please check your credentials and try again"
          break
        end
      rescue => e
        last_error = e
        puts "Error downloading bundle: will try #{max_tries-tries} more times"
      end
    end

    if bundle.nil? 
       puts "An error occured while downloading the bundle"
      raise last_error if last_error
    end
    # Save the bundle to the measures directory
    FileUtils.mkdir_p measures_dir
    FileUtils.mv(bundle.path, File.join(measures_dir, @bundle_name))

  end

  desc %{ Download and install the measure/test deck bundle.  This is essientally delegating to the bundle_download and bundle:import tasks
    options
    nlm_user    - the nlm username to authenticate to the server - will prompt is not supplied
    nlm_passwd  - the nlm password for authenticating to the server - will prompt if not supplied 
    version     - the version of the bundle to download. This will default to the version 
                  declared in the config/cypress.yml file or to the latest version if one does not exist there"
    delete_existing - delete any existing bundles with the same version and reinstall - default is false - will cause error if same version already exists
    update_measures - update any existing measures with the same hqmf_id to those contained in this bundle. 
                      Will only work for bundle versions greater than that of the installed version - default is false
    type -  type of measures to be installed from bundle. A bundle may have measures of different types such as ep or eh.  This will constrain the types installed, defautl is all types
   example usage:
    rake cypress:bundle_download_and_install nlm_name=username nlm_passwd=password version=2.1.0-latest  type=ep                
  }
  task :bundle_download_and_install => [:download_bundle] do
    de = ENV['delete_existing'] || false
    um = ENV['update_measures'] || false
    puts "Importing bundle #{@bundle_name} delete_existing: #{de}  update_measures: #{um} type: #{ENV['type'] || 'ALL'}"
    task("bundle:import").invoke("bundles/#{@bundle_name}",de, um , ENV['type'])
  end


end



