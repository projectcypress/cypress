# frozen_string_literal: true

require 'test_helper'

class ProductsHelperTest < ActiveJob::TestCase
  include ProductsHelper
  # include ActiveJob::TestHelper

  def setup
    drop_database
    @bundle = FactoryBot.create(:static_bundle)
    @user = FactoryBot.create(:vendor_user)
    @user.save!
    @vendor = FactoryBot.create(:vendor)
    @product = @vendor.products.create!(name: 'test_product', c1_test: true, c2_test: true, c3_test: true, c4_test: true, bundle_id: @bundle.id,
                                        randomize_patients: false, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    setup_checklist_test
    setup_measure_tests
    setup_filtering_tests
  end

  def setup_checklist_test
    checklist_test = @product.product_tests.build({ name: 'c1 visual', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
    checklist_test.save!
    checked_criterias = []
    measures = Measure.where(:hqmf_id.in => checklist_test.measure_ids, :bundle_id => @product.bundle_id)
    measures.each do |measure|
      # chose criteria randomly
      criterias = measure['source_data_criteria'].sort_by { rand }[0..4]
      criterias.each do |criteria|
        checked_criterias.push(measure_id: measure.id.to_s, source_data_criteria: criteria, attribute_index: 0, completed: false)
      end
    end
    checklist_test.checked_criteria = checked_criterias
    checklist_test.save!
  end

  def setup_measure_tests
    @product.product_tests.build({ name: 'test_product_test_name_1',
                                   measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    # MeasureTest needs provider
    @product.save!
    @product.product_tests.build({ name: 'test_product_test_name_2',
                                   measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    @product.save!
    @product.product_tests.measure_tests.each do |test|
      test.tasks.build({}, C1Task)
      test.tasks.build({}, C2Task)
      test.tasks.build({}, C3Cat1Task)
      test.tasks.build({}, C3Cat3Task)
    end
  end

  def setup_filtering_tests
    @product.product_tests.create!({ name: 'Filter Test 1', cms_id: 'CMS32v7', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                     options: { filters: { filt1: ['val1'], filt2: ['val2'] } } }, FilteringTest)
    @product.product_tests.filtering_tests.each do |test|
      test.tasks.build({}, Cat1FilterTask)
      test.tasks.build({}, Cat3FilterTask)
    end
  end

  # # # # # # # # #
  #   T E S T S   #
  # # # # # # # # #

  def test_should_show_product_tests_tab
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    vendor = @product.vendor
    vendor.products.each(&:destroy)
    product = vendor.products.create!(name: "my product test #{rand}", c1_test: true, c2_test: true, c4_test: true, measure_ids:, bundle_id: @bundle.id)

    # should show measure tests
    assert_equal true, should_show_product_tests_tab?(product, 'MeasureTest')

    # should show filtering tests
    assert_equal true, should_show_product_tests_tab?(product, 'FilteringTest')

    # should not show filtering tests
    product.c4_test = false
    assert_equal false, should_show_product_tests_tab?(product, 'FilteringTest')

    # should show checklist test tab
    assert_equal true, should_show_product_tests_tab?(product, 'ChecklistTest')

    # should not show checklist test tab
    product.c1_test = false
    product.c2_test = true
    assert_equal false, should_show_product_tests_tab?(product, 'ChecklistTest')

    # should not show measure tests
    product.c2_test = false
    assert_equal false, should_show_product_tests_tab?(product, 'MeasureTest')
  end

  def test_perform_c3_certification_during_measure_test_message
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    vendor = @product.vendor
    vendor.products.each(&:destroy)
    product = vendor.products.create!(name: "my product test #{rand}", c1_test: true, measure_ids:, bundle_id: @bundle.id)

    # no message since c3_test is not true
    assert_equal '', perform_c3_certification_during_measure_test_message(product, 'MeasureTest')

    # no message since test type is not 'MeasureTest'
    product.c3_test = true
    product.save!
    assert_equal '', perform_c3_certification_during_measure_test_message(product, 'FilteringTest')

    # message only has c1
    assert_equal ' C3 certifications will automatically be performed during C1 certifications.',
                 perform_c3_certification_during_measure_test_message(product, 'MeasureTest')

    # message has both c1 and c2
    product.c2_test = true
    product.save!
    assert_equal ' C3 certifications will automatically be performed during C1 and C2 certifications.',
                 perform_c3_certification_during_measure_test_message(product, 'MeasureTest')

    # message only has c2
    product.c1_test = false
    product.save!
    assert_equal ' C3 certifications will automatically be performed during C2 certifications.',
                 perform_c3_certification_during_measure_test_message(product, 'MeasureTest')
  end

  def test_should_reload_product_test_link
    product = @product
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    # product test not ready
    pt = ProductTest.new(state: :not_ready, name: 'my product test name 1', measure_ids:, product:)
    task = pt.tasks.build
    pt.save!
    task.save!
    assert_equal true, should_reload_product_test_link?(tasks_status([task]), pt)

    # product test is ready, task is pending
    pt = ProductTest.new(state: :ready, name: 'my product test name 2', measure_ids:, product:)
    tasks = build_tasks_with_test_execution_states([:pending], pt)
    pt.save!
    assert_equal true, should_reload_product_test_link?(tasks_status(tasks), pt)

    # product test is ready, task is completed execution and is in a passing state
    pt = ProductTest.new(state: :ready, name: 'my product test name 3', measure_ids:, product:)
    tasks = build_tasks_with_test_execution_states([:passed], pt)
    pt.save!
    assert_equal false, should_reload_product_test_link?(tasks_status(tasks), pt)

    # product test is ready, one task not pending while other task is pending
    pt = ProductTest.new(state: :ready, name: 'my product test name 4', measure_ids:, product:)
    tasks = build_tasks_with_test_execution_states(%i[passed pending], pt)
    pt.save!
    assert_equal true, should_reload_product_test_link?(tasks_status(tasks), pt)
  end

  def setup_product_test_and_task_for_should_reload_measure_test_row_test
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    vendor = Vendor.create!(name: "my vendor #{rand}")
    product = vendor.products.create!(name: "my product #{rand}", measure_ids:, bundle_id: @bundle.id, c1_test: true)
    product_test = product.product_tests.create!(state: :pending, name: "my product test #{rand}", measure_ids:)
    task = product_test.tasks.create!
    [product_test, task]
  end

  def test_should_reload_measure_test_row
    product_test, task = setup_product_test_and_task_for_should_reload_measure_test_row_test

    # product test with :pending state should need reloading
    assert_equal true, measure_test_running_for_row?(task)

    # if task has a pending most recent execution then needs reloading
    execution = task.test_executions.create!(state: :pending, user: @user)
    assert_equal true, measure_test_running_for_row?(task)

    # if task has a passing most recent execution and it has been less than 30 seconds then the page does need reloading
    execution.state = :passed
    execution.save!
    assert_equal true, measure_test_running_for_row?(task)

    # if execution has a sibling execution that is pending then needs reloading
    sibling_task = product_test.tasks.create!
    sibling_execution = sibling_task.test_executions.create!(sibling_execution_id: execution.id, state: :pending, user: @user)
    execution.sibling_execution_id = sibling_execution.id
    execution.save!
    assert_equal true, measure_test_running_for_row?(task)

    # if both executions are finished and it has been less than 30 seconds then the page does need reloading
    sibling_execution.state = :failed
    sibling_execution.save!
    assert_equal true, measure_test_running_for_row?(task)
  end

  def test_should_not_reload_measure_test_row
    product_test, task = setup_product_test_and_task_for_should_reload_measure_test_row_test

    # product test with :ready state should not need reloading
    product_test.state = :ready
    product_test.save!
    assert_equal false, measure_test_running_for_row?(task)

    # if task has a passing most recent execution and it has been more than 30 seconds then the page doesn't need reloading
    execution = task.test_executions.create!(state: :passed, updated_at: Time.now.utc - 1.minute, user: @user)
    assert_equal false, measure_test_running_for_row?(task)

    # if both executions are finished and it has been more than 30 seconds then the page does not need reloading
    sibling_task = product_test.tasks.create!
    sibling_execution = sibling_task.test_executions.create!(
      sibling_execution_id: execution.id,
      state: :failed,
      user: @user
    )
    sibling_execution.updated_at = Time.now.utc - 1.minute
    sibling_execution.save!
    execution.sibling_execution_id = sibling_execution.id
    execution.updated_at = Time.now.utc - 1.minute
    execution.save!
    assert_equal false, measure_test_running_for_row?(task)
  end

  def test_tasks_status
    assert_equal 'passing', tasks_status(build_tasks_with_test_execution_states([:passed]))
    assert_equal 'failing', tasks_status(build_tasks_with_test_execution_states([:failed]))
    # As soon as a task has a test execution created then the state is considered pending.
    assert_equal 'pending', tasks_status(build_tasks_with_test_execution_states([:other_state]))
    # If a task does not have any test executions associated then it is considered incomplete.
    assert_equal 'incomplete', tasks_status([Task.new])

    assert_equal 'passing', tasks_status(build_tasks_with_test_execution_states(%i[passed passed]))
    assert_equal 'failing', tasks_status(build_tasks_with_test_execution_states(%i[passed failed]))
    assert_equal 'pending', tasks_status(build_tasks_with_test_execution_states(%i[passed other_state]))

    assert_equal 'failing', tasks_status(build_tasks_with_test_execution_states(%i[failed failed]))
    assert_equal 'failing', tasks_status(build_tasks_with_test_execution_states(%i[failed other_state]))

    assert_equal 'pending', tasks_status(build_tasks_with_test_execution_states(%i[other_state other_state]))
  end

  def build_tasks_with_test_execution_states(states, product_test = nil)
    tasks = []
    if product_test.nil?
      product = @product
      measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
      # product test is ready, task is pending
      product_test = ProductTest.new(state: :ready, name: 'my product test name 2', measure_ids:, product:)
    end
    states.each do |state|
      task = Task.new
      task.product_test = product_test
      task.save!
      task.test_executions.create!(state:, user: @user)
      tasks << task
    end
    tasks
  end

  def test_with_c3_task
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    product = Product.new(vendor: @vendor.id, name: 'my product', c1_test: true, c2_test: true, bundle_id: @bundle.id,
                          measure_ids:)
    product.save!
    pt = ProductTest.new(name: 'my product test name 1', measure_ids:, product:)
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

    assert_equal [c2_task, c3_cat3_task], with_c3_task(c2_task)
    replace_with_eh_measure(pt.measures.first)
    assert_equal [c1_task, c3_cat1_task], with_c3_task(c1_task)
  end

  def test_each_tab_c1_only
    make_product_certify(@product, c1_test: true, c2_test: false, c3_test: false, c4_test: false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 2, test_types.count, 'should only have a record sample tab'
    assert_equal 'C1 Sample', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
  end

  def test_each_tab_c1_c2
    make_product_certify(@product, c1_test: true, c2_test: true, c3_test: false, c4_test: false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 3, test_types.count, 'should have record sample, c1 measure, and c2 measure tabs'
    assert_equal 'C1 Sample', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
    assert_equal 'C2 (QRDA-III)', titles[2]
  end

  def test_each_tab_c1_c3_eh
    make_product_certify(@product, c1_test: true, c2_test: false, c3_test: true, c4_test: false)
    replace_with_eh_measure(@product.product_tests.first.measures.first)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 3, test_types.count, 'should only have record sample tab'
    assert_equal 'C1 + C3 Sample', titles[0]
    assert_equal 'C1 + C3 (QRDA-I)', titles[1]
    assert_equal 'C3 (QRDA-III)', titles[2]
  end

  def test_each_tab_c1_c4
    make_product_certify(@product, c1_test: true, c2_test: false, c3_test: false, c4_test: true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 3, test_types.count, 'should have record sample tab and filtering test tab'
    assert_equal 'C1 Sample', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[2]
  end

  def test_each_tab_c1_c3_c4_ep
    make_product_certify(@product, c1_test: true, c2_test: false, c3_test: true, c4_test: true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 4, test_types.count, 'should have record sample tab and filtering test tab'
    assert_equal 'C1 Sample', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
    assert_equal 'C3 (QRDA-III)', titles[2]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[3]
  end

  def test_each_tab_c1_c2_c3_only_eh
    make_product_certify(@product, c1_test: true, c2_test: true, c3_test: true, c4_test: false)
    replace_with_eh_measure(@product.product_tests.first.measures.first)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 3, test_types.count, 'should have record sample, c1 measure, and c2 measure tabs'
    assert_equal 'C1 + C3 Sample', titles[0]
    assert_equal 'C1 + C3 (QRDA-I)', titles[1]
    assert_equal 'C2 (QRDA-III)', titles[2]
  end

  def test_each_tab_c1_c2_c3_only_ep
    make_product_certify(@product, c1_test: true, c2_test: true, c3_test: true, c4_test: false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 3, test_types.count, 'should have record sample, c1 measure, and c2 measure tabs'
    assert_equal 'C1 Sample', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
    assert_equal 'C2 + C3 (QRDA-III)', titles[2]
  end

  def test_each_tab_c1_c2_c4
    make_product_certify(@product, c1_test: true, c2_test: true, c3_test: false, c4_test: true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 4, test_types.count, 'should have record sample, c1 measure, c2 measure, and c4 filtering tabs'
    assert_equal 'C1 Sample', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
    assert_equal 'C2 (QRDA-III)', titles[2]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[3]
  end

  def test_each_tab_c1_c2_c3_c4_only_eh
    make_product_certify(@product, c1_test: true, c2_test: true, c3_test: true, c4_test: true)
    replace_with_eh_measure(@product.product_tests.first.measures.first)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 4, test_types.count, 'should have record sample, c1 measure, c2 measure, and c4 filtering tabs'
    assert_equal 'C1 + C3 Sample', titles[0]
    assert_equal 'C1 + C3 (QRDA-I)', titles[1]
    assert_equal 'C2 (QRDA-III)', titles[2]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[3]
  end

  def test_each_tab_c1_c2_c3_c4_only_ep
    make_product_certify(@product, c1_test: true, c2_test: true, c3_test: true, c4_test: true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 4, test_types.count, 'should have record sample, c1 measure, c2 measure, and c4 filtering tabs'
    assert_equal 'C1 Sample', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
    assert_equal 'C2 + C3 (QRDA-III)', titles[2]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[3]
  end

  def test_each_tab_c2_only
    make_product_certify(@product, c1_test: false, c2_test: true, c3_test: false, c4_test: false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 1, test_types.count, 'should only have a c2 measure tab'
    assert_equal 'C2 (QRDA-III)', titles[0]
  end

  def test_each_tab_c2_c3
    make_product_certify(@product, c1_test: false, c2_test: true, c3_test: true, c4_test: false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 2, test_types.count, 'should only have c2 measure tab'
    assert_equal 'C3 (QRDA-I)', titles[0]
    assert_equal 'C2 + C3 (QRDA-III)', titles[1]
  end

  def test_each_tab_c2_c4
    make_product_certify(@product, c1_test: false, c2_test: true, c3_test: false, c4_test: true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 2, test_types.count, 'should have c2 measure and c4 filtering tabs'
    assert_equal 'C2 (QRDA-III)', titles[0]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[1]
  end

  def test_each_tab_c2_c3_c4
    make_product_certify(@product, c1_test: false, c2_test: true, c3_test: true, c4_test: true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 3, test_types.count, 'should have c2 measure and c4 filtering tabs'
    assert_equal 'C3 (QRDA-I)', titles[0]
    assert_equal 'C2 + C3 (QRDA-III)', titles[1]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[2]
  end

  def get_test_types_titles_and_descriptions(product)
    test_types = []
    titles = []
    descriptions = []
    each_tab(product) do |test_type, title|
      test_types << test_type
      titles << title
      descriptions << 'description'
    end
    [test_types, titles, descriptions]
  end

  def make_product_certify(product, c1_test: false, c2_test: false, c3_test: false, c4_test: false)
    product.c1_test = c1_test
    product.c2_test = c2_test
    product.c3_test = c3_test
    product.c4_test = c4_test
    product.save!
    product.product_tests.checklist_tests.each(&:destroy) unless c1_test
    product.product_tests.measure_tests.each(&:destroy) unless c2_test
    product.product_tests.filtering_tests.each(&:destroy) unless c4_test
  end

  def test_measure_test_tasks
    assert(measure_test_tasks(@product, get_c1_tasks: true).all? { |task| task.is_a? C1Task })
    assert(measure_test_tasks(@product, get_c1_tasks: false).all? { |task| task.is_a? C2Task })
  end

  def replace_with_eh_measure(measure)
    measure.reporting_program_type = 'eh'
    measure.save
  end
end
