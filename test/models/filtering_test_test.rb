require 'test_helper'

class FilteringTestTest < ActiveJob::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
    vendor = Vendor.create(name: 'test_vendor_name')
    @product = vendor.products.create(name: 'test_product', c2_test: true, c4_test: true)
  end

  def test_create
    assert_enqueued_jobs 0
    options = { 'filters' => {} }
    ft = @product.product_tests.build({ name: 'test_for_measure_1a',
                                        measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'],
                                        bundle_id: '4fdb62e01d41c820f6000001', options: options }, FilteringTest)

    assert ft.valid?
    perform_enqueued_jobs do
      assert ft.save, 'should be able to save valid Filtering test'
      assert_performed_jobs 1
      assert ft.records.count > 0, 'Filtering test creation should have created random number of test records'
      ft.reload
      assert_not_nil ft.patient_archive, 'Filtering test should have archived patient records'
      assert_not_nil ft.expected_results, 'Filtering test should have expected results'
    end
  end

  def test_pick_filter_criteria
    criteria = %w(races ethnicities genders payers providers)
    options = { 'filters' => Hash[criteria.map { |c| [c, []] }] }
    ft = FilteringTest.new(name: 'test_for_measure_1a', product: @product, options: options,
                           measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'], bundle_id: '4fdb62e01d41c820f6000001')
    ft.save!
    ft.generate_records
    ft.reload
    ft.pick_filter_criteria
    options_assertions(ft)
  end

  def options_assertions(ft)
    assert ft.options['filters']['races'].count == 1
    assert ft.options['filters']['ethnicities'].count == 1
    assert ft.options['filters']['genders'].count == 1
    assert ft.options['filters']['payers'].count == 1
    assert ft.options['filters']['providers'].count == 1
  end

  def _jesse_setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
    vendor = Vendor.create!(name: 'test_vendor_name')
    product = vendor.products.create!(name: 'test_product', c4: true)
    @test = product.product_tests.create({}, FilteringTest)
  end

  def _jesse_test_create_tasks
    vendor = Vendor.create!(name: 'vendor_afjkdsfl')
    product = vendor.products.create!(name: 'test_product', c4_test: true)
    @test = product.product_tests.create({}, FilteringTest)
  end

  def _jesse_test_creates_tasks
    @test.create_tasks
    assert_not_nil @test.cat1_task
    assert_not_nil @test.cat3_task
  end

  def _jesse_test_task_status_with_existing_tasks
    test = @product.product_tests.create({}, FilteringTest)
    test.create_tasks
    test.tasks.first.test_executions.build(:state => :passed).save!

    assert_equal 'passing', test.task_status('Cat1FilterTask')
    assert_equal 'incomplete', test.task_status('Cat3FilterTask')
  end

  def _jesse_test_task_status_with_non_existant_tasks
    test = @product.product_tests.create({}, FilteringTest)
    assert_equal 'incomplete', test.task_status('Cat1FilterTask')
    assert_equal 'incomplete', test.task_status('Cat3FilterTask')
  end

  def _jesse_test_cat1_and_cat3_tasks
    test = @product.product_tests.create({}, FilteringTest)
    assert_equal test.cat1_task, false
    assert_equal test.cat3_task, false

    test.create_tasks
    assert_not_equal test.cat1_task, false
    assert_not_equal test.cat3_task, false
  end
end
