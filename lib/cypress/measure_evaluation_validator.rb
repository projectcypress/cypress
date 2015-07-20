# :nocov:
module Cypress
  class MeasureEvaluationValidator

    @@cda_header = {:identifier=>{:root=>"CypressRoot", :extension=>"CypressExtension"},
     :authors=>
      [{:ids=>[{:root=>"authorRoot", :extension=>"authorExtension"}],
        :device=>{:name=>"deviceName", :model=>"deviceModel"},
        :addresses=>[],
        :telecoms=>[],
        :time=>nil,
        :organization=>{:ids=>[{:root=>"authorsOrganizationRoot", :extension=>"authorsOrganizationExt"}], :name=>""}}],
     :custodian=>{:ids=>[{:root=>"custodianRoot", :extension=>"custodianExt"}],
                  :person=>{:given=>"", :family=>""}, :organization=>{:ids=>[{:root=>"custodianOrganizationRoot",
                  :extension=>"custodianOrganizationExt"}], :name=>""}},
     :legal_authenticator=>
      {:ids=>[{:root=>"legalAuthenticatorRoot", :extension=>"legalAuthenticatorExt"}],
       :addresses=>[],
       :telecoms=>[],
       :time=>nil,
       :person=>{:given=>nil, :family=>nil},
       :organization=>{:ids=>[{:root=>"legalAuthenticatorOrgRoot", :extension=>"legalAuthenticatorOrgExt"}], :name=>""}}}

    def initialize(args = nil)
      @options = args
    end

    # Removes cached data and any prior tests from cypress
    def cleanup(args = nil)
      opts = args ? @options.merge(args) : @options

      print "Cleaning database..."

      ProductTest.where({name: "measureEvaluationTest"}).each do |test|
        Result.where({"value.test_id" => test.id}).destroy_all
        QME::QualityReport.where({"test_id" => test.id}).destroy_all
        HealthDataStandards::CQM::QueryCache.where({"test_id" => test.id}).destroy_all
        test.destroy
      end

      p = Product.where({name: "MeasureEvaluationProduct"}).first
      ProductTest.where({_type: "QRDAProductTest", product: p}).destroy_all

      Vendor.where({name: "MeasureEvaluationVendor"}).destroy_all
      Product.where({name: "MeasureEvaluationProduct"}).destroy_all

      puts "done"
    end

    # Runs all the single-measure QRDA Cat 3 tests
    def evaluate_all_singly(args = nil)

      opts = args ? @options.merge(args) : @options

      generate_cat3_tests(opts)

      wait_for_calculations

      upload_all_cat3s

    end

    def evaluate_non_passing_cat3s(args = nil)
      opts = args ? @options.merge(args) : @options

      generate_cat3_tests(opts)

      wait_for_calculations

      upload_cat3s(CalculatedProductTest.all.select{ |pt| pt if pt.execution_state != :passed })
    end

    # Runs all multi-measure QRDA Cat 3 tests
    def evaluate_multi_measures(args = nil)
      opts = args ? @options.merge(args) : @options

      print "Generating tests..."

      num_tests = opts[:num_tests].to_i
      num_measures = opts[:num_measures].to_i

      # Get lists of all the EP and EH measure HQMF IDs, so we can grab a random sampling of them for the test
      all_ep_measures = Measure.top_level_by_type('ep').pluck(:hqmf_id)
      all_eh_measures = Measure.top_level_by_type('eh').pluck(:hqmf_id)

      test_ids = (1..num_tests).collect do |n|
        # Even tests are EP, odd tests are EH
        if n.even?
          opts[:measure_ids] = all_ep_measures.sample(num_measures)
          opts[:test_type] = 'CalculatedProductTest'
        else
          opts[:measure_ids] = all_eh_measures.sample(num_measures)
          opts[:test_type] = 'InpatientProductTest'
        end
        self.generate_test(opts).id
      end

      puts "done"

      wait_for_calculations

      upload_cat3s(ProductTest.where({"_id" => {"$in" => test_ids}}))

    end

    # Generates all cat3 tests as single tests, then generates a cat1 test for each,
    # then downloads a Cat1 zip and uploads it to Cypress
    def evaluate_all_cat1(args = nil)
      opts = args ? @options.merge(args) : @options

      cat3_tests = generate_cat3_tests(opts)

      wait_for_calculations

      generate_cat1_tests(cat3_tests)

      print "Creating and uploading Cat I zips..."

      p = Product.where({name: "MeasureEvaluationProduct"}).first
      ProductTest.where({_type: "QRDAProductTest", product: p}).each do |t|
        begin
          zip = create_cat1_zip(t)
          FileUtils.mv zip, "#{File.dirname(zip)}/#{File.basename(zip)}.zip"
          zip2 = File.new("#{File.dirname(zip)}/#{File.basename(zip)}.zip")
          t.execute(zip2)
        rescue NoMethodError => e
          $stderr.puts "Cat 1 test #{t.id} failed: #{e}"
        end
      end

      puts "done"
    end

    # Generates all the cat1 tests for any passed-in cat3 tests
    def generate_cat1_tests(cat3_tests, args = nil)
      opts = args ? @options.merge(args) : @options

      print "Generating Cat I tests..."

      cat3_tests.each do |t|
        if !ProductTest.where({_type: "QRDAProductTest", calculated_product_test: t.id}).exists?
          t.generate_qrda_cat1_test
        end
      end

      puts "done"
    end

    #creates a Zip of cat Is for a product test
    def create_cat1_zip(product_test)
      Cypress::CreateDownloadZip.create_test_zip(product_test.id, "qrda")
    end

    # Waits until there are no tests with a state not equal to "ready"
    def wait_for_calculations
      print "Waiting for calculations to finish..."

      continuing = true
      while (continuing)
        sleep(2)
        continuing = ProductTest.where({:name => "measureEvaluationTest", :state => {"$ne" => :ready}}).exists?
      end

      puts "done"
    end

    # Generates a Cat III test for each top level measure
    def generate_cat3_tests(args = nil)
      opts = args ? @options.merge(args) : @options

      print "Generating Cat III tests..."

      tests = Measure.top_level.collect do |t|
        opts[:test_type] = t.type == "ep" ? "CalculatedProductTest" : "InpatientProductTest"
        opts[:measure_ids] = [t.hqmf_id]
        self.generate_test(opts)
      end

      puts "done"
      return tests
    end

    # Generates a test based on the measure_ids hash passed in, then creates the downloadable patient zip
    # NOTE: doesn't currently check to make sure the test type matches the measures passed in (I.E. Calculated for ep, Inpatient for eh)
    # RETURNS: A handle to the zip file
    def generate_test(args = nil)
      opts = args ? @options.merge(args) : @options
      user = opts[:cypress_user] ? User.where({email: opts[:cypress_user]}).first : User.first
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first
      test_type = opts[:test_type] ? opts[:test_type] : "CalculatedProductTest"

      vendor = Vendor.find_or_create_by({name: "MeasureEvaluationVendor", user_id: user.id})
      product = Product.find_or_create_by({name: "MeasureEvaluationProduct", vendor_id: vendor.id})
      product.users << user
      product.save
      product_test_class = test_type.camelize.constantize
      product_test = product_test_class.find_or_create_by({name: "measureEvaluationTest",
                                                          bundle: bundle.id,
                                                          effective_date: bundle.effective_date,
                                                          product: product,
                                                          measure_ids: opts[:measure_ids],
                                                          description: opts[:measure_ids].join(", ")})
      product_test.user = user
      product_test.save
      product_test
    end

    # Generates a QRDA Cat 3 for a particular test
    def generate_cat3(measure_ids, test_id)
      exporter = HealthDataStandards::Export::Cat3.new
      effective_date = Time.gm(APP_CONFIG['effective_date']['year'],APP_CONFIG['effective_date']['month'],APP_CONFIG['effective_date']['day'], 23, 59, 59)
      end_date = Time.at(effective_date.to_i)
      filter = measure_ids==["all"] ? {} : {:hqmf_id.in => measure_ids}
      return exporter.export(HealthDataStandards::CQM::Measure.top_level.where(filter),
                              generate_header,
                              effective_date.to_i,
                              end_date.years_ago(1),
                              end_date, nil, test_id)
    end

    def script_generate_cat3(measure_ids, test)
      zip = create_cat1_zip(test)
      print "running test for measures #{measure_ids}..."
      file = `bundle exec ruby ./script/cat_3_calculator.rb #{measure_opts_for(measure_ids)} --zipfile #{zip.path}`
      puts "done"
      return file
    end

    def measure_opts_for(measure_ids)
      return "--measure " + measure_ids.join(" --measure ")
    end

    # Generates the QRDA/CDA header, using the header info above
    def generate_header(provider = nil)
      header = Qrda::Header.new(@@cda_header)

      header.identifier.root = UUID.generate
      header.authors.each {|a| a.time = Time.now}
      header.legal_authenticator.time = Time.now
      header.performers << provider

      header
    end

    # Uploads all cat 3's, and dumps failure data to the terminal
    def upload_all_cat3s
      puts "Generating and uploading QRDA Cat 3s..."

      upload_cat3s(ProductTest.where({:name => "measureEvaluationTest"}))

      puts "done"
    end

    def upload_cat3s(tests)
      tests.each do |t|
        # if !t.measure_ids.include?("40280381-4555-E1C1-0145-D7C003364261")
          begin
            xml = script_generate_cat3(t.measure_ids, t)
            upload_cat3(t, xml)
          rescue Exception => e
            $stderr.puts "Cat 3 test #{t.id} failed: #{e}"
          end
        # end
      end
    end

    # Uploads a single Cat 3
    def upload_cat3(product_test, xml)
      # Generate a temporary file that acts just like a normal file, but is given a unique name in the './tmp' directory
      tmp = Tempfile.new(['qrda_upload', '.xml'], './tmp')
      tmp.write(xml)
      product_test.execute(tmp)
    end

  end
end
# :nocov:
