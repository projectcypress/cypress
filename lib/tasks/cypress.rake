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
                     :terms_and_conditions =>  "1",
                     :admin =>          true,
                     :approved =>       true)
    admin_account.save!
  end


  task :set_admin, [:user_email]=> :setup do |t,args|
    admin_account = User.where({:email => args.user_email}).first
    admin_account[:admin] = true
    admin_account.save!
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
