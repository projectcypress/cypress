require 'test_helper'

class ProductsHelperTest < ActiveJob::TestCase
  include ProductsHelper
  # include ActiveJob::TestHelper

  def setup
    drop_database
    collection_fixtures('records', 'measures', 'vendors', 'products', 'product_tests', 'bundles')

    @product = Product.new(vendor: Vendor.all.first, name: 'test_product', c1_test: true, c2_test: true, c3_test: true, c4_test: true,
                           bundle_id: '4fdb62e01d41c820f6000001')

    setup_checklist_test
    setup_measure_tests
    setup_filtering_tests
  end

  def setup_checklist_test
    checklist_test = @product.product_tests.build({ name: 'c1 visual', measure_ids: ['40280381-43DB-D64C-0144-5571970A2685'] }, ChecklistTest)
    checklist_test.save!
    checked_criterias = []
    measures = Measure.top_level.where(:hqmf_id.in => checklist_test.measure_ids)
    measures.each do |measure|
      # chose criteria randomly
      criterias = measure['hqmf_document']['source_data_criteria'].sort_by { rand }.first(5)
      criterias.each do |criteria_key, _criteria_value|
        checked_criterias.push(measure_id: measure.id.to_s, source_data_criteria: criteria_key, completed: false)
      end
    end
    checklist_test.checked_criteria = checked_criterias
    checklist_test.save!
  end

  def setup_measure_tests
    @product.product_tests.build({ name: 'test_product_test_name_1',
                                   measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'] }, MeasureTest).save!
    @product.product_tests.build({ name: 'test_product_test_name_2',
                                   measure_ids: ['8A4D92B2-3887-5DF3-0139-11B262260A92'] }, MeasureTest).save!
    @product.product_tests.measure_tests.each do |test|
      test.tasks.build({}, C1Task)
      test.tasks.build({}, C2Task)
      test.tasks.build({}, C3Cat1Task)
      test.tasks.build({}, C3Cat3Task)
    end
  end

  def setup_filtering_tests
    @product.product_tests.create!({ name: 'Filter Test 1', cms_id: 'SomeCMSID', measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'],
                                     options: { filters: { filt1: ['val1'], filt2: ['val2'] } }
                                   }, FilteringTest)
    @product.product_tests.filtering_tests.each do |test|
      test.tasks.build({}, Cat1FilterTask)
      test.tasks.build({}, Cat3FilterTask)
    end
  end

  # # # # # # # # #
  #   T E S T S   #
  # # # # # # # # #

  def test_checklist_status_values_not_started
    test = @product.product_tests.checklist_tests.first
    passing, failing, not_started, total = checklist_status_values(test)

    assert_equal 0, passing
    assert_equal 0, failing
    assert_equal 1, not_started
    assert_equal 1, total
  end

  def test_checklist_status_values_failing
    test = @product.product_tests.checklist_tests.first
    test.checked_criteria.first.completed = true
    passing, failing, not_started, total = checklist_status_values(test)

    assert_equal 0, passing
    assert_equal 1, failing
    assert_equal 0, not_started
    assert_equal 1, total
  end

  def test_checklist_status_values_passing
    test = @product.product_tests.checklist_tests.first
    test.checked_criteria.each { |criteria| criteria.completed = true }
    passing, failing, not_started, total = checklist_status_values(test)

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 0, not_started
    assert_equal 1, total
  end

  def test_product_test_status_values_not_started
    passing, failing, not_started, total = product_test_status_values(@product.product_tests.measure_tests, 'C1Task')

    assert_equal 0, passing
    assert_equal 0, failing
    assert_equal total, not_started
  end

  def test_product_test_status_values_passing
    tests = @product.product_tests.measure_tests
    tests.first.tasks.where(_type: 'C1Task').first.test_executions.build(:state => :passed).save
    passing, failing, not_started, total = product_test_status_values(tests, 'C1Task')

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 1, not_started
    assert_equal 2, total
  end

  def test_product_test_status_values_failing
    tests = @product.product_tests.measure_tests
    tests.first.tasks.where(_type: 'C1Task').first.test_executions.build(:state => :failed).save
    passing, failing, not_started, total = product_test_status_values(tests, 'C1Task')

    assert_equal 0, passing
    assert_equal 1, failing
    assert_equal 1, not_started
    assert_equal 2, total
  end

  def test_filtering_test_status_values_summed_not_started
    tests = @product.product_tests.filtering_tests
    passing, failing, not_started, total = filtering_test_status_values_summed(tests)

    assert_equal 0, passing
    assert_equal 0, failing
    assert_equal not_started, total
  end

  def test_filtering_test_status_values_summed_passing
    tests = @product.product_tests.filtering_tests
    tests.first.tasks.where(_type: 'Cat1FilterTask').first.test_executions.build(:state => :passed).save
    passing, failing, not_started, total = filtering_test_status_values_summed(tests)

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 1, not_started
    assert_equal 2, total
  end

  def test_filtering_test_status_values_summed_failing
    tests = @product.product_tests.filtering_tests
    tests.first.tasks.where(_type: 'Cat1FilterTask').first.test_executions.build(:state => :failed).save
    passing, failing, not_started, total = filtering_test_status_values_summed(tests)

    assert_equal 0, passing
    assert_equal 1, failing
    assert_equal 1, not_started
    assert_equal 2, total
  end

  def test_generate_filter_records
    @product.product_tests = nil
    @product.add_filtering_tests(Measure.where(hqmf_id: '40280381-4600-425F-0146-1F8D3B750FAC').first)
    records = @product.product_tests.filtering_tests.first.records
    @product.product_tests.filtering_tests.each { |ft| assert ft.records == records }
  end

  def test_product_test_status_values_cat1
    tests = @product.product_tests.measure_tests
    c1_execution = tests.first.tasks.where(_type: 'C1Task').first.test_executions.build(:state => :failed)
    c3_execution = tests.first.tasks.where(_type: 'C3Cat1Task').first.test_executions.build(:state => :passed)
    c1_execution.sibling_execution_id = c3_execution.id
    c1_execution.save
    c3_execution.save
    passing, failing, not_started, total = product_test_status_values(tests, 'C3Cat1Task')

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 1, passing
    assert_equal 2, total
  end

  def test_product_test_status_values_cat3
    tests = @product.product_tests.measure_tests
    c2_execution = tests.first.tasks.where(_type: 'C2Task').first.test_executions.build(:state => :failed)
    c3_execution = tests.first.tasks.where(_type: 'C3Cat3Task').first.test_executions.build(:state => :passed)
    c2_execution.sibling_execution_id = c3_execution.id
    c2_execution.save
    c3_execution.save
    passing, failing, not_started, total = product_test_status_values(tests, 'C3Cat3Task')

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 1, passing
    assert_equal 2, total
  end

  def test_all_records_for_product
    records = all_records_for_product(@product)
    assert_equal 0, records.length
  end
end
