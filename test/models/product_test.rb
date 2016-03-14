require 'test_helper'
require 'helpers/caching_test'

class ProducTest < ActiveSupport::TestCase
  def setup
    collection_fixtures('measures', 'bundles')
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
    drop_database
  end

  def test_create
    pt = Product.new(vendor: @vendor, name: 'test_product', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
  end

  def test_create_from_vendor
    pt = @vendor.products.build(name: 'test_product', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
  end

  def test_must_have_name
    pt = Product.new(vendor: @vendor, c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without a name'
  end

  def test_must_have_vendor
    pt = Product.new(name: 'test_product', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without a vendor'
  end

  def test_must_have_at_least_one_certification_test_type
    pt = Product.new(vendor: @vendor, name: 'test_product', measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without at least one certification type'
  end

  def test_must_certify_to_c1_or_c2
    pt = Product.new(vendor: @vendor, name: 'test_product', c3_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without C1 or C2'
  end

  def test_can_have_multiple_certification_test_types
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save with two certification types'
  end

  def test_measure_tests
    pt = Product.new(vendor: @vendor, name: 'measure_test', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build({ name: 'test_product_test_name',
                             measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                             bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest).save!
    assert pt.product_tests.measure_tests
    assert_equal pt.product_tests.measure_tests.count, 1
  end

  def test_no_checklist_test
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.product_tests.checklist_tests.exists?
  end

  def test_create_checklist_test
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.product_tests.build({ name: 'test_checklist_test',
                             measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                             bundle_id: '4fdb62e01d41c820f6000001' }, ChecklistTest).save!
    assert pt.product_tests.checklist_tests.exists?
  end

  def test_add_filtering_tests
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'])
    pt.add_filtering_tests
    assert pt.product_tests.filtering_tests.count == 5
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
