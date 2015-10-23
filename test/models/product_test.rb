require 'test_helper'

class ProducTest < MiniTest::Test
  def setup
    @vendor = Vendor.new(name: 'test_vendor_name')
    @vendor.save

    ActionController::Base.perform_caching = true
    @old_cache_store = ActionController::Base.cache_store
    ActionController::Base.cache_store = :memory_store, { size: 64.megabytes }
    Rails.cache.clear
  end

  def teardown
    ActionController::Base.perform_caching = false
    ActionController::Base.cache_store = @old_cache_store
  end

  def after_teardown
    Product.all.destroy
    Vendor.all.destroy
  end

  def test_create
    pt = Product.new(vendor: @vendor, name: 'test_product', ehr_type: 'provider')
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
  end

  def test_create_from_vendor
    pt = @vendor.products.build(name: 'test_product', ehr_type: 'provider')
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
  end

  def test_must_have_name
    pt = Product.new(vendor: @vendor, ehr_type: 'provider')
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without a name'
  end

  def test_must_have_vendor
    pt = Product.new(name: 'test_product', ehr_type: 'provider')
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without a vendor'
  end

  def test_must_have_ehr_type
    pt = Product.new(vendor: @vendor, name: 'test_product')
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without an ehr_type'
  end

  def test_ehr_type_hospital_is_valid
    pt = Product.new(vendor: @vendor, name: 'test_product', ehr_type: 'hospital')
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to save with ehr_type of hospital'
  end

  def test_invalid_ehr_type
    pt = Product.new(vendor: @vendor, name: 'test_product', ehr_type: 'other')
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save with invalid ehr_type'
  end
end

class ProductCachingTest < CachingTest
  def test_product_status_and_product_test_groups_are_not_cached_on_start
    assert !Rails.cache.exist?("#{@product.cache_key}/status"), 'cache key for product status should not exist'
    assert !Rails.cache.exist?("#{@product.cache_key}/product_tests_passing"), "cache key for product's passing product tests should not exist"
    assert !Rails.cache.exist?("#{@product.cache_key}/product_tests_failing"), "cache key for product's failing product tests should not exist"
    assert !Rails.cache.exist?("#{@product.cache_key}/product_tests_incomplete"), "cache key for product's incomplete product tests should not exist"
  end

  def test_product_status_is_cached_after_checking_status
    @product.status
    assert Rails.cache.exist?("#{@product.cache_key}/status"), 'cache key for product status should exist'
  end

  def test_product_test_groups_are_cached_after_checking_each
    @product.product_tests_passing
    @product.product_tests_failing
    @product.product_tests_incomplete
    assert Rails.cache.exist?("#{@product.cache_key}/product_tests_passing"), "cache key for product's passing products tests should exist"
    assert Rails.cache.exist?("#{@product.cache_key}/product_tests_failing"), "cache key for product's failing products tests should exist"
    assert Rails.cache.exist?("#{@product.cache_key}/product_tests_incomplete"), "cache key for product's incomplete products tests should exist"
  end
end
