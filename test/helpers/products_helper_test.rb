require 'test_helper'

class ProductsHelperTest < ActiveJob::TestCase
  include ProductsHelper
  # include ActiveJob::TestHelper

  def setup
    drop_database
    collection_fixtures('records', 'measures', 'vendors', 'products', 'product_tests', 'bundles')

    @product = Product.new(vendor: Vendor.all.first, name: 'test_product', c1_test: true, c2_test: true, c3_test: true, c4_test: true,
                           bundle_id: '4fdb62e01d41c820f6000001', measure_ids: ['40280381-43DB-D64C-0144-5571970A2685'])
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

  def test_generate_filter_records
    @product.product_tests = nil
    @product.add_filtering_tests
    records = @product.product_tests.filtering_tests.first.records
    @product.product_tests.filtering_tests.each { |ft| assert ft.records == records }
  end

  def test_all_records_for_product
    records = all_records_for_product(@product)
    assert_equal 0, records.length
  end

  def test_should_reload_product_test_link
    product = Product.new
    measure_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
    # product test not ready
    pt = ProductTest.new(:state => :not_ready, :name => 'my product test name 1', :measure_ids => measure_ids, :product => product)
    task = pt.tasks.build
    pt.save!
    task.save!
    assert_equal true, should_reload_product_test_link?([task])

    # product test is ready, task is pending
    pt = ProductTest.new(:state => :ready, :name => 'my product test name 2', :measure_ids => measure_ids, :product => product)
    tasks = build_tasks_with_test_execution_states([:pending]).each { |tsk| tsk.product_test = pt }
    pt.save!
    assert_equal true, should_reload_product_test_link?(tasks)

    # product test is ready, task is not pending
    pt = ProductTest.new(:state => :ready, :name => 'my product test name 3', :measure_ids => measure_ids, :product => product)
    tasks = build_tasks_with_test_execution_states([:other_state]).each { |tsk| tsk.product_test = pt }
    pt.save!
    assert_equal false, should_reload_product_test_link?(tasks)

    # product test is ready, one task not pending while other task is pending
    pt = ProductTest.new(:state => :ready, :name => 'my product test name 4', :measure_ids => measure_ids, :product => product)
    tasks = build_tasks_with_test_execution_states([:other_state, :pending]).each { |tsk| tsk.product_test = pt }
    pt.save!
    assert_equal true, should_reload_product_test_link?(tasks)
  end

  def test_tasks_status
    assert_equal 'passing', tasks_status(build_tasks_with_test_execution_states([:passed]))
    assert_equal 'failing', tasks_status(build_tasks_with_test_execution_states([:failed]))
    assert_equal 'incomplete', tasks_status(build_tasks_with_test_execution_states([:other_state]))

    assert_equal 'passing', tasks_status(build_tasks_with_test_execution_states([:passed, :passed]))
    assert_equal 'failing', tasks_status(build_tasks_with_test_execution_states([:passed, :failed]))
    assert_equal 'incomplete', tasks_status(build_tasks_with_test_execution_states([:passed, :other_state]))

    assert_equal 'failing', tasks_status(build_tasks_with_test_execution_states([:failed, :failed]))
    assert_equal 'failing', tasks_status(build_tasks_with_test_execution_states([:failed, :other_state]))

    assert_equal 'incomplete', tasks_status(build_tasks_with_test_execution_states([:other_state, :other_state]))
  end

  def build_tasks_with_test_execution_states(states)
    tasks = []
    states.each do |state|
      task = Task.new
      task.save!
      task.test_executions.create!(state: state)
      tasks << task
    end
    tasks
  end

  def test_with_c3_task
    measure_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
    product = Product.new(vendor: Vendor.all.first, name: 'my product', c1_test: true, c2_test: true, bundle_id: '4fdb62e01d41c820f6000001',
                          measure_ids: measure_ids)
    product.save!
    pt = ProductTest.new(name: 'my product test name 1', measure_ids: measure_ids, product: product)
    pt.save!
    c1_task = pt.tasks.build({}, C1Task)
    c2_task = pt.tasks.build({}, C2Task)
    pt.tasks.each(&:save!)
    assert_equal [c1_task], with_c3_task(c1_task)
    assert_equal [c2_task], with_c3_task(c2_task)

    product.c3_test = true
    c3_cat1_task = pt.tasks.build({}, C3Cat1Task)
    c3_cat3_task = pt.tasks.build({}, C3Cat3Task)
    pt.tasks.each(&:save!)
    assert_equal [c1_task, c3_cat1_task], with_c3_task(c1_task)
    assert_equal [c2_task, c3_cat3_task], with_c3_task(c2_task)
  end
end
