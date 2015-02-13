require 'quality-measure-engine'
require 'health-data-standards'
require 'fileutils'
require 'open-uri'
require 'highline/import'




 class RebuildJob < Struct.new(:test_id)

  def perform
   qrda = ProductTest.find(self.test_id)
    qrda.results.destroy
    ct = CalculatedProductTest.where({"_id" => qrda["calculated_test_id"]}).first
    if ct.nil?
       puts "could not update QRDA Test #{qrda.product.vendor.name} -> #{qrda.product.name} -> #{qrda.name} "
      return
    end
    qrda.measures.top_level.each do |mes|
      results = ct.results.where({"value.measure_id" => mes.hqmf_id, "value.IPP" => {"$gt" => 0}})
      results.uniq!
      results.each do |res|
        res_clone = Result.new()
        res_clone["value"] = res["value"].clone
        res_clone["value"]["test_id"]=qrda.id
        res_clone.save
      end
    end
  end
end

namespace :cypress do

  task :setup => :environment


  desc "Delete all collections from the database related to the Cypress workflow (e.g. vendors, products, etc)"
  task :reset => :setup do
    Mongoid.default_session.database.drop()
  end

  desc "Recalculate all of the tests"
  task :recalculate_tests  => :setup do

    Delayed::Job.where({}).destroy
    total = CalculatedProductTest.where({}).count
    puts "About to recalculate #{total} EP/EH QRDA Cat III tests"
    CalculatedProductTest.where({}).each_with_index do |pt|
      puts "Recalculating #{pt.name}"
      pt.results.destroy
      MONGO_DB["query_cache"].where({"test_id" => pt.id}).remove_all
      Cypress::MeasureEvaluationJob.new({"test_id" =>  pt.id.to_s}).perform
     end

    puts "Resetting #{QRDAProductTest.where({}).count} QRDA Cat I tests"
    QRDAProductTest.where({}).each do |pt|
      RebuildJob.new(pt.id).perform
    end
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
    bundle_uri = "https://demo.projectcypress.org/bundles/#{@bundle_name}"
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
        sleep 0.5
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
    task("bundle:import").invoke("bundles/#{@bundle_name}",de, um , ENV['type'], 'true')
  end

task :test_qrda_files, [:version, :type] => :setup do |t,args|
  bundle = args.version ? Bundle.where({version: args.version}).first : Bundle.first
  if bundle.nil?
    puts "Could not find bundle with version #{args.version}"
    return
  end
  Delayed::Worker.delay_jobs = false


  types = args.type == "all" ? ["ep","eh"] : [args.type]
  vendor = Vendor.find_or_create_by({name: "RakeTestVendor"})

  runtime = Time.now
  errors = {}
  types.each do |type|
    puts "Generating Product for testing #{type} - #{runtime}"
    product = vendor.products.find_or_create_by({name: "#{type} - #{runtime}"})
    measures = bundle.measures.where({type: type})

    puts "Generating #{type} product tests"

    measures.each do |mes|
      puts "Generating #{mes.nqf_id} calculated product test"
      ptest = CalculatedProductTest.new(effective_date: bundle.effective_date, bundle_id: bundle.id, name: "#{mes.nqf_id}", product_id: product.id, measure_ids: [mes.hqmf_id] )
      ptest.save
      puts "Generating #{mes.nqf_id} QRDA product tests"
      ptest.generate_qrda_cat1_test

      qrda_tests = QRDAProductTest.where({calculated_test_id: ptest.id})
      qrda_tests.each do |qtest|
        puts "Executing #{qtest.name}"
        FileUtils.mkdir_p("./tmp/qrda_test/")
        #download records
        file = Cypress::CreateDownloadZip.create_test_zip(qtest.id,"qrda")
        File.open("./tmp/qrda_test/#{qtest.name.gsub(' ','_')}.zip", "w") do |f|
          f.puts file.read
        end
        #execute test
        te = qtest.execute({results:  File.new("./tmp/qrda_test/#{qtest.name.gsub(' ','_')}.zip")})
        errors[qtest] = te.execution_errors

      end
     end
   end
    errors.each_pair do |k,errs|
     if errs && errs.length > 0
        puts k.name
        errs.group_by{|e| e.msg_type}.each_pair do |type, errs|

          puts type
          errs.collect(&:message).each{|m| puts m}
        end
        puts

     end
    end
  end

  namespace :cleanup do
    task :setup => :environment

    desc "Remove temporary items (such as vendors, tests, etc) from the database, without removing existing users"
    task :database => :setup do
      print "Cleaning database..."
      Delayed::Job.destroy_all
      before = Vendor.all.count
      Vendor.destroy_all
      diff = before - Vendor.all.count
      Result.destroy_all("value.test_id"=> {"$ne" => nil})
      QME::QualityReport.destroy_all(:test_id => {"$ne"=> nil})
      Record.destroy_all(:test_id => {"$ne" => nil})
      Artifact.destroy_all
      puts "removed #{diff} Vendors"
    end

    desc "Get rid of files in tmp/cache"
    task :temp_files => :setup do
      print "Cleaning temp files..."
      task("tmp:cache:clear").invoke
      Rails.cache.clear
      puts "done"
    end

    desc "Provide statistics on numbers of vendors/tests/etc generated"
    task :cypress_statistics => :setup do
      puts "Vendors,products,tests,executions"
      puts "#{Vendor.all.count},#{Product.all.count},#{ProductTest.all.count},#{TestExecution.all.count}"
    end

    task :all => [:environment, :database, :temp_files]
  end
end
