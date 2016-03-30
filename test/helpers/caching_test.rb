require 'test_helper'

class CachingTest < ActiveSupport::TestCase
  def setup
    collection_fixtures('measures', 'bundles')

    ActionController::Base.perform_caching = true

    setup_vendor
    setup_product_with_product_test
    setup_task
    setup_test_execution
  end

  def setup_vendor
    @vendor = Vendor.new(name: 'test_vendor_name')
    @vendor.save!
  end

  def setup_product_with_product_test
    @product = Product.new(name: 'test_product_name', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    @product.bundle = Bundle.find('4fdb62e01d41c820f6000001')
    @product_test = ProductTest.new(name: 'test_product_test_name',
                                    measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    @product.vendor = @vendor
    @product_test.product = @product
    @product_test.save!
    @product.save!
  end

  def setup_task
    @c1_task = C1Task.new
    @c1_task.product_test = @product_test
    @c1_task.save!
  end

  def setup_test_execution
    @test_execution = TestExecution.new
    @test_execution.task = @c1_task
    @test_execution.save!
  end

  def teardown
    Rails.cache.clear
    ActionController::Base.perform_caching = false

    drop_database
  end
end
