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
    measure_id = '8A4D92B2-397A-48D2-0139-B0DC53B034A7'

    # without c3 tasks
    test = create_product_with_product_test_and_tasks(measure_id, true, true, false, false)
    assert_equal [test.tasks.c1_task], with_c3_task(test.tasks.c1_task)
    assert_equal [test.tasks.c2_task], with_c3_task(test.tasks.c2_task)

    # with c3 tasks
    test = create_product_with_product_test_and_tasks(measure_id, true, true, true, false)
    assert_equal [test.tasks.c1_task, test.tasks.c3_cat1_task], with_c3_task(test.tasks.c1_task)
    assert_equal [test.tasks.c2_task, test.tasks.c3_cat3_task], with_c3_task(test.tasks.c2_task)

    # filtering tests should only return same task
    test = create_product_with_product_test_and_tasks(measure_id, true, true, false, true)
    assert_equal [test.tasks.cat1_filter_task], with_c3_task(test.tasks.cat1_filter_task)
    assert_equal [test.tasks.cat3_filter_task], with_c3_task(test.tasks.cat3_filter_task)

    # filtering tests should only return same tasks, even if c3_test selected
    test = create_product_with_product_test_and_tasks(measure_id, true, true, true, true)
    assert_equal [test.tasks.cat1_filter_task], with_c3_task(test.tasks.cat1_filter_task)
    assert_equal [test.tasks.cat3_filter_task], with_c3_task(test.tasks.cat3_filter_task)
  end

  def test_tasks_needing_reload
    measure_id = '8A4D92B2-397A-48D2-0139-B0DC53B034A7'

    # no tasks should need reload if no test executions exist
    test = create_product_with_product_test_and_tasks(measure_id, true, true, true, true)
    assert_equal 0, tasks_needing_reload(test.product).count

    # task with test execution pending should need a reload
    test = create_product_with_product_test_and_tasks(measure_id, true, true, true, true)
    test.tasks.c1_task.test_executions.create!(:state => :pending)
    tasks = tasks_needing_reload(test.product)
    assert_equal 1, tasks.count
    assert_equal test.tasks.c1_task, tasks.first

    # tasks with test executions pending should need reloading
    test = create_product_with_product_test_and_tasks(measure_id, true, true, true, true)
    test.tasks.c1_task.test_executions.create!(:state => :pending)
    test.tasks.cat1_filter_task.test_executions.create!(:state => :pending)
    assert_equal 2, tasks_needing_reload(test.product).count

    # all tasks with building product test should need reloading
    test = create_product_with_product_test_and_tasks(measure_id, true, true, true, true)
    test.state = :building
    test.save!
    # exclude both c3 tasks from needing reload since c3 test executions are run through c1 and c2 tasks
    tasks = tasks_needing_reload(test.product)
    assert_equal 4, tasks.count
    tasks.each do |task|
      assert %w(C1Task C2Task Cat1FilterTask Cat3FilterTask).include? task.class.to_s
    end
  end

  def test_tasks_needing_reload_with_test_executions
    measure_id = '8A4D92B2-397A-48D2-0139-B0DC53B034A7'

    # any tasks that have a test execution and are pending should be reloaded
    test = create_product_with_product_test_and_tasks(measure_id, true, true, true, true)
    test.tasks.c1_task.test_executions.create!(:state => :pending)
    assert_equal 1, tasks_needing_reload(test.product).count
    test.tasks.c2_task.test_executions.create!(:state => :pending)
    test.reload
    assert_equal 2, tasks_needing_reload(test.product).count
    test.tasks.cat1_filter_task.test_executions.create!(:state => :passed)
    test.reload
    assert_equal 2, tasks_needing_reload(test.product).count
  end

  def create_product_with_product_test_and_tasks(measure_id, c1_test, c2_test, c3_test, c4_test)
    product = Product.new(vendor: Vendor.all.first, name: "my product #{rand}", c1_test: c1_test, c2_test: c2_test, c3_test: c3_test,
                          c4_test: c4_test, bundle_id: '4fdb62e01d41c820f6000001', measure_ids: [measure_id])
    product.save!
    test = ProductTest.new(:name => "my product test #{rand}", :measure_ids => [measure_id], :product => product, :state => :ready)
    test.save!
    if c1_test
      test.tasks.build({}, C1Task)
      test.tasks.build({}, C3Cat1Task) if c3_test
    end
    if c2_test
      test.tasks.build({}, C2Task)
      test.tasks.build({}, C3Cat3Task) if c3_test
    end
    if c4_test
      test.tasks.build({}, Cat1FilterTask)
      test.tasks.build({}, Cat3FilterTask)
    end
    test.tasks.each(&:save!)
    test
  end
end
