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

      vendor = Vendor.find_or_create_by(name: 'MeasureEvaluationVendor')
      product = Product.find_or_create_by(name: 'MeasureEvaluationProduct', vendor_id: vendor.id, c2_test: true, c3_test: true)

      product_test = MeasureTest.find_or_create_by(name: opts[:measure].name,
                                                   bundle: bundle.id,
                                                   product: product,
                                                   measure_ids: [opts[:measure].hqmf_id],
                                                   description: opts[:measure].description,
                                                   cms_id: opts[:measure].cms_id)
      product_test.save
      product_test
    end
  end
end
