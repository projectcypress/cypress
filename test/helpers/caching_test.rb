require 'test_helper'

class CachingTest < MiniTest::Test
  def setup
    collection_fixtures('measures', 'bundles')

    ActionController::Base.perform_caching = true
    @old_cache_store = ActionController::Base.cache_store
    ActionController::Base.cache_store = :memory_store, { size: 64.megabytes }
    Rails.cache.clear

    setup_vendor
    setup_product
    setup_product_test
    setup_task
    setup_test_execution
  end

  def setup_vendor
    @vendor = Vendor.new(name: 'test_vendor_name')
    @vendor.save!
  end

  def setup_product
    @product = Product.new(name: 'test_product_name', ehr_type: 'provider')
    @product.vendor = @vendor
    @product.save!
  end

  def setup_product_test
    @product_test = ProductTest.new(name: 'test_product_test_name')
    @product_test.product = @product
    @product_test.bundle = Bundle.all.first
    @product_test.measure_id = Measure.all.first.id
    @product_test.effective_date = 1
    @product_test.save!
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
    ActionController::Base.perform_caching = false
    ActionController::Base.cache_store = @old_cache_store
  end

  def after_teardown
    drop_database
  end

  # Vendor

  #
  #   Product
  #

  #
  #   Product Test
  #

  #
  #   Task
  #

  #
  #   Updating
  #
end
