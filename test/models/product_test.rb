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
    pt = Product.new(vendor: @vendor, name: 'test_product', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
  end

  def test_create_from_vendor
    pt = @vendor.products.build(name: 'test_product', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
  end

  def test_must_have_name
    pt = Product.new(vendor: @vendor, c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without a name'
  end

  def test_must_have_vendor
    pt = Product.new(name: 'test_product', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without a vendor'
  end

  def test_must_have_at_least_one_certification_test_type
    pt = Product.new(vendor: @vendor, name: 'test_product', measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without at least one certification type'
  end

  def test_must_certify_to_c1_or_c2_or_c4
    pt = Product.new(vendor: @vendor, name: 'test_product', c3_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without C1, C2, or C4'
  end

  def test_can_have_multiple_certification_test_types
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save with two certification types'
  end

  def test_measure_tests
    pt = Product.new(vendor: @vendor, name: 'measure_test', c1_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build({ name: 'test_product_test_name',
                             measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                             bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest).save!
    assert pt.product_tests.measure_tests
    assert_equal pt.product_tests.measure_tests.count, 1
  end

  def test_no_checklist_test
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                           bundle_id: '4fdb62e01d41c820f6000001').save!
    assert_not pt.product_tests.checklist_tests.exists?
  end

  def test_create_checklist_test
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'], bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build({ name: 'test_checklist_test',
                             measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                             bundle_id: '4fdb62e01d41c820f6000001' }, ChecklistTest).save!
    assert pt.product_tests.checklist_tests.exists?
  end

  def test_update_with_measure_tests_creates_measure_tests_if_c2_selected
    measure_ids = ['40280381-4BE2-53B3-014C-0F589C1A1C39']
    product = @vendor.products.new
    params = { name: "my product #{rand}", c2_test: true, 'measure_ids' => measure_ids, bundle_id: '4fdb62e01d41c820f6000001' }
    product.update_with_measure_tests(params)
    assert_equal measure_ids.count, product.product_tests.measure_tests.count
    assert_equal measure_ids.first, product.product_tests.measure_tests.first.measure_ids.first
    assert_equal 0, product.product_tests.checklist_tests.count
  end

  def test_update_with_measure_tests_creates_no_measure_tests_if_c2_not_selected
    measure_ids = ['40280381-4BE2-53B3-014C-0F589C1A1C39']
    product = @vendor.products.new
    params = { name: "my product #{rand}", c1_test: true, 'measure_ids' => measure_ids, bundle_id: '4fdb62e01d41c820f6000001' }
    product.update_with_measure_tests(params)
    assert_equal 0, product.product_tests.measure_tests.count
    assert_equal 1, product.product_tests.checklist_tests.count
  end

  def test_add_filtering_tests
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'],
                     bundle_id: '4fdb62e01d41c820f6000001')
    pt.save!
    pt.add_filtering_tests
    assert_equal 5, pt.product_tests.filtering_tests.count
  end

  def test_add_checklist_test
    pt = Product.new(vendor: @vendor, name: 'my_product', c1_test: true, measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'],
                     bundle_id: '4fdb62e01d41c820f6000001')
    pt.product_tests.build({ name: 'first measure test', measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'] }, MeasureTest)
    pt.save!
    pt.add_checklist_test
    assert pt.product_tests.checklist_tests.count > 0
    assert pt.product_tests.checklist_tests.first.measure_ids.include? '40280381-4BE2-53B3-014C-0F589C1A1C39'

    # test if old product test can be deleted (since measure with id ending in 1C39 was removed) and new checklist test created
    pt.product_tests.destroy { |test| test }
    pt.product_tests.build({ name: 'second measure test', measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'] }, MeasureTest)
    pt.measure_ids = ['40280381-4B9A-3825-014B-C1A59E160733']
    pt.save!
    pt.add_checklist_test
    assert pt.product_tests.checklist_tests.count > 0
    assert pt.product_tests.checklist_tests.first.measure_ids.include? '40280381-4B9A-3825-014B-C1A59E160733'

    # test checklist tests should not change if new measures are added to product
    old_checklist_test = pt.product_tests.checklist_tests.first
    pt.product_tests.build({ name: 'third measure test', measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'] }, MeasureTest)
    pt.save!
    pt.add_checklist_test
    assert pt.product_tests.checklist_tests.first == old_checklist_test
  end

  def test_add_checklist_test_adds_tests_and_tasks_if_appropriate
    measure_id = '40280381-4B9A-3825-014B-C1A59E160733'
    product = @vendor.products.create!(name: "my product #{rand}", measure_ids: [measure_id], c2_test: true, bundle_id: '4fdb62e01d41c820f6000001')
    product.product_tests.create!({ name: "my measure test #{rand}", measure_ids: [measure_id] }, MeasureTest)

    # should create no product tests if c1 was not selected
    product.add_checklist_test
    assert_equal 0, product.product_tests.checklist_tests.count

    # should create only a c1_manual_task if only c1 and not c3 is selected
    product.c1_test = true
    product.save!
    product.add_checklist_test
    assert_equal 1, product.product_tests.checklist_tests.count
    assert_equal 1, product.product_tests.checklist_tests.first.tasks.count
    assert_equal C1ManualTask, product.product_tests.checklist_tests.first.tasks.first.class

    product.product_tests.checklist_tests.each(&:destroy)
    assert_equal 0, product.product_tests.checklist_tests.count

    # should create c1_manual_task and c3_manual_task if both c1 and c3 are selected
    product.c3_test = true
    product.save!
    product.add_checklist_test
    assert_equal 1, product.product_tests.checklist_tests.count
    assert_equal 2, product.product_tests.checklist_tests.first.tasks.count

    manual_tasks = product.product_tests.checklist_tests.first.tasks
    assert arrays_equivalent(manual_tasks.collect(&:class), [C1ManualTask, C3ManualTask])
  end

  def test_add_checklist_test_adds_correct_number_of_measures_for_checked_criteria
    measure_ids = ['40280381-4B9A-3825-014B-C1A59E160733', '40280381-4BE2-53B3-014C-0F589C1A1C39']
    product = @vendor.products.create!(name: "my product #{rand}", measure_ids: measure_ids, c1_test: true, bundle_id: '4fdb62e01d41c820f6000001')
    CAT1_CONFIG['number_of_checklist_measures'] = 1

    # create measure tests for each of the measure ids
    product.measure_ids.each do |measure_id|
      product.product_tests.create!({ name: "measure test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
    end

    # should only create checked criteria for a single measure
    product.add_checklist_test
    assert_equal 1, product.product_tests.checklist_tests.count
    assert_equal 1, product.product_tests.checklist_tests.first.measures.count

    # remove all measure tests so creating checked criteria will use all measures
    # also remove all checklist tests
    product.product_tests.each(&:destroy)

    # should create checked criteria for all measures
    product.add_checklist_test
    assert_equal 1, product.product_tests.checklist_tests.count
    assert_equal product.measure_ids.count, product.product_tests.checklist_tests.first.measures.count
  end

  # # # # # # # # # # # # # # # #
  #   S T A T U S   T E S T S   #
  # # # # # # # # # # # # # # # #

  def test_product_status
    product = Product.new(vendor: @vendor, name: 'my product', c1_test: true, measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'], bundle_id: '4fdb62e01d41c820f6000001')
    product.save!
    product_test = product.product_tests.build({ name: 'my product test 1', measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'] }, MeasureTest)
    product_test.save!

    # status should be incomplete if all product tests passing but no manual checklist test exists
    product_test.tasks.first.test_executions.create!(:state => :passed)
    assert_equal 'incomplete', product.status

    # if product does not need to certify for c1, than product should pass
    product.c1_test = nil
    product.c2_test = true
    product.save!
    assert_equal 'passing', product.status
    product.c1_test = true
    product.c2_test = nil
    product.save!

    # adding a complete checklist test will make product pass
    create_complete_checklist_test_for_product(product, product.measure_ids.first)
    assert_equal 'passing', product.status

    # one failing product test will fail the product
    product_test = product.product_tests.build({ name: 'my product test 2', measure_ids: ['8A4D92B2-3887-5DF3-0139-0D01C6626E46'] }, MeasureTest)
    product_test.save!
    product_test.tasks.first.test_executions.create!(:state => :failed)
    assert_equal 'failing', product.status
  end

  def test_product_status_failing_if_one_product_test_are_fails
    measure_id = '40280381-4BE2-53B3-014C-0F589C1A1C39'
    product = Product.new(vendor: @vendor, name: 'my product', c1_test: true, measure_ids: [measure_id], bundle_id: '4fdb62e01d41c820f6000001')
    product_test = product.product_tests.build({ name: "my product test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
    product_test.save!
    product_test.tasks.first.test_executions.build(:state => :passed)
    product.save!
  end

  def create_complete_checklist_test_for_product(product, measure_id)
    # id_of_measure is _id attribute on measure. checked_criteria use this mongoid id as a unique identifier for measures to avoid submeasures
    id_of_measure = Measure.top_level.where(hqmf_id: measure_id, bundle_id: product.bundle_id).first.id
    criterias = [ChecklistSourceDataCriteria.new(code: 'my code', attribute_code: 'my attribute code', recorded_result: 'my recorded result',
                                                 code_complete: true, attribute_complete: true, result_complete: true,
                                                 passed_qrda: true, measure_id: id_of_measure)]
    checklist_test = product.product_tests.build({ name: 'my checklist test', checked_criteria: criterias,
                                                   measure_ids: [measure_id] }, ChecklistTest)
    checklist_test.save!
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
    @product.product_tests_for_status('passing')
    @product.product_tests_for_status('failing')
    @product.product_tests_for_status('incomplete')
    assert Rails.cache.exist?("#{@product.cache_key}/product_tests_passing"), "cache key for product's passing products tests should exist"
    assert Rails.cache.exist?("#{@product.cache_key}/product_tests_failing"), "cache key for product's failing products tests should exist"
    assert Rails.cache.exist?("#{@product.cache_key}/product_tests_incomplete"), "cache key for product's incomplete products tests should exist"
  end
end
