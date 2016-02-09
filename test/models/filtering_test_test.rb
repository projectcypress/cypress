require 'test_helper'

class FilteringTestTest < ActiveJob::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures', 'health_data_standards_svs_value_sets')
    vendor = Vendor.create(name: 'test_vendor_name')
    @product = vendor.products.create(name: 'test_product', randomize_records: true, c2_test: true, c4_test: true)
  end

  def test_create
    assert_enqueued_jobs 0
    options = { 'filters' => {} }
    ft = @product.product_tests.build({ name: 'test_for_measure_1a',
                                        measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'],
                                        bundle_id: '4fdb62e01d41c820f6000001', options: options }, FilteringTest)

    assert ft.valid?
  end

  def test_pick_filter_criteria
    criteria = %w(races ethnicities genders payers providers problems)
    options = { 'filters' => Hash[criteria.map { |c| [c, []] }] }
    ft = FilteringTest.new(name: 'test_for_measure_1a', product: @product, options: options,
                           measure_ids: ['8A4D92B2-397A-48D2-0139-C648B33D5582'], bundle_id: '4fdb62e01d41c820f6000001')
    ft.save!
    ft.generate_records
    ft.reload
    ft.pick_filter_criteria
    options_assertions(ft)
  end

  def options_assertions(filter_test)
    assert filter_test.options['filters']['races'].count == 1
    assert filter_test.options['filters']['ethnicities'].count == 1
    assert filter_test.options['filters']['genders'].count == 1
    assert filter_test.options['filters']['payers'].count == 1
    providers_assertions(filter_test)
    assert filter_test.options['filters']['problems'].count == 1
  end

  def providers_assertions(filter_test)
    assert filter_test.options['filters']['providers']['npis']
    assert filter_test.options['filters']['providers']['tins']
    assert filter_test.options['filters']['providers']['addresses']
  end

  def test_task_status_with_existing_tasks
    test = @product.product_tests.create({}, FilteringTest)
    test.create_tasks
    test.tasks.first.test_executions.build(:state => :passed).save!

    assert_equal 'passing', test.task_status('Cat1FilterTask')
    assert_equal 'incomplete', test.task_status('Cat3FilterTask')
  end

  def test_task_status_with_non_existant_tasks
    test = @product.product_tests.create({}, FilteringTest)
    assert_equal 'incomplete', test.task_status('Cat1FilterTask')
    assert_equal 'incomplete', test.task_status('Cat3FilterTask')
  end

  def test_cat1_and_cat3_tasks
    test = @product.product_tests.create({}, FilteringTest)
    assert_equal test.cat1_task, false
    assert_equal test.cat3_task, false

    test.create_tasks
    assert_not_equal test.cat1_task, false
    assert_not_equal test.cat3_task, false
  end
end
