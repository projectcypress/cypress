# :nocov:
module Cypress
  class MeasureEvaluator
    def initialize(args = nil)
      @options = args ? args : {}
      @logger = Rails.logger
    end

    def evaluate_all_cat3(args = nil)
      opts = args ? @options.merge(args) : @options
      generate_cat3_tests(opts)

      wait_for_calculations

      upload_all_cat3s
    end

    def cleanup(*)
      @logger.info 'Cleaning database...'
      Vendor.where(name: 'MeasureEvaluationVendor').destroy_all
      @logger.info 'done'
    end

    def generate_cat3_tests(args = nil)
      opts = args ? @options.merge(args) : @options

      @logger.info 'Generating Cat III tests...'
      tests = Measure.top_level.collect do |t|
        opts[:measure] = t
        generate_test(opts)
      end
      @logger.info 'done'
      tests
    end

    def generate_test(args = nil)
      opts = args ? @options.merge(args) : @options
      bundle_ver = opts[:version] ? opts[:version] : APP_CONFIG['default_bundle']
      bundle = Bundle.where(version: bundle_ver).first

      @logger.info "Generating test for #{opts[:measure].cms_id}"

      vendor = Vendor.find_or_create_by(name: 'MeasureEvaluationVendor')
      product = Product.find_or_create_by(name: 'MeasureEvaluationProduct', vendor_id: vendor.id, c1_test: true, c2_test: true, c3_test: true)

      product_test = MeasureTest.find_or_create_by(name: opts[:measure].name,
                                                   bundle: bundle.id,
                                                   product: product,
                                                   measure_ids: [opts[:measure].hqmf_id],
                                                   description: opts[:measure].description,
                                                   cms_id: opts[:measure].cms_id)
      product_test.save
      product_test
    end

    # Waits until there are no tests with a state not equal to "ready"
    def wait_for_calculations
      @logger.info 'Waiting for calculations to finish...'
      product = Product.where(name: 'MeasureEvaluationProduct').first

      continuing = true
      while continuing
        sleep(2)
        continuing = ProductTest.where(state: 'pending', product: product).count > 0
      end

      @logger.info 'done'
    end

    def upload_all_cat3s
      @logger.info 'Generating and uploading QRDA Cat 3s...'

      upload_cat3s(Product.where(name: 'MeasureEvaluationProduct').first.product_tests)

      @logger.info 'done'
    end

    def upload_cat3s(tests)
      tests.each do |t|
        begin
          xml = generate_cat3(t.measure_ids, t)
          upload_cat3(t, xml)
        rescue StandardError => e
          @logger.error "Cat 3 test #{t.id} failed: #{e}"
        end
      end
    end

    # Uploads a single Cat 3
    def upload_cat3(product_test, xml)
      # Generate a temporary file that acts just like a normal file, but is given a unique name in the './tmp' directory
      tmp = Tempfile.new(['qrda_upload', '.xml'], './tmp')
      tmp.write(xml)
      product_test.tasks.find { |t| t._type == 'C2Task' }.execute(tmp)
    end

    def generate_cat3(measure_ids, test)
      zip = create_cat1_zip(test)
      @logger.info "running test for measures #{measure_ids}..."
      file = `bundle exec ruby ./script/cat_3_calculator.rb #{measure_opts_for(measure_ids)} --zipfile #{zip.path}`
      @logger.info 'done'
      file
    end

    def measure_opts_for(measure_ids)
      '--measure ' + measure_ids.join(' --measure ')
    end

    # creates a Zip of cat Is for a product test
    def create_cat1_zip(product_test)
      Cypress::CreateDownloadZip.create_test_zip(product_test.id, 'qrda')
    end
  end
end
