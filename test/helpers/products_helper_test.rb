require 'test_helper'

class ProductsHelperTest < ActiveJob::TestCase
  include ProductsHelper
  # include ActiveJob::TestHelper

  def setup
    drop_database
    collection_fixtures('records', 'measures', 'vendors', 'products', 'product_tests', 'bundles')

    @product = Product.new(vendor: Vendor.find('4f57a8791d41c851eb000002'), name: 'test_product', c1_test: true, c2_test: true, c3_test: true, c4_test: true,
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
      criterias = measure['hqmf_document']['source_data_criteria'].sort_by { rand }[0..4]
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
    records = @product.product_tests.filtering_tests.find_by(cms_id: 'CMS31v3').records
    @product.product_tests.filtering_tests.each { |ft| assert ft.records == records }
  end

  def test_all_records_for_product
    records = all_records_for_product(@product)
    assert_equal 0, records.length
  end

  def test_should_show_product_tests_tab
    measure_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
    vendor = @product.vendor
    vendor.products.each(&:destroy)
    product = vendor.products.create!(name: "my product test #{rand}", c1_test: true, measure_ids: measure_ids, bundle_id: '4fdb62e01d41c820f6000001')
    product.measure_ids.each do |measure_id|
      product.product_tests.create!({ name: "my measure test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
      product.product_tests.create!({ name: "my filtering test for measure id #{measure_id}", measure_ids: [measure_id] }, FilteringTest)
    end

    # should show measure tests
    assert_equal true, should_show_product_tests_tab?(product, 'MeasureTest')

    # should not show measure tests
    product.product_tests.measure_tests.each(&:destroy)
    assert_equal false, should_show_product_tests_tab?(product, 'MeasureTest')

    # should show filtering tests
    assert_equal true, should_show_product_tests_tab?(product, 'FilteringTest')

    # should not show filtering tests
    product.product_tests.filtering_tests.each(&:destroy)
    assert_equal false, should_show_product_tests_tab?(product, 'FilteringTest')

    # should show checklist test tab
    assert_equal true, should_show_product_tests_tab?(product, 'ChecklistTest')

    # should not show checklist test tab
    product.c1_test = false
    product.c2_test = true
    product.save!
    assert_equal false, should_show_product_tests_tab?(product, 'ChecklistTest')
  end

  def test_perform_c3_certification_during_measure_test_message
    measure_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
    vendor = @product.vendor
    vendor.products.each(&:destroy)
    product = vendor.products.create!(name: "my product test #{rand}", c1_test: true, measure_ids: measure_ids, bundle_id: '4fdb62e01d41c820f6000001')

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

  def setup_product_test_and_task_for_should_reload_measure_test_row_test
    measure_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
    vendor = Vendor.create!(name: "my vendor #{rand}")
    product = vendor.products.create!(name: "my product #{rand}", measure_ids: measure_ids, bundle_id: '4fdb62e01d41c820f6000001', c1_test: true)
    product_test = product.product_tests.create!(:state => :pending, :name => "my product test #{rand}", :measure_ids => measure_ids)
    task = product_test.tasks.create!
    [product_test, task]
  end

  def test_should_reload_measure_test_row
    product_test, task = setup_product_test_and_task_for_should_reload_measure_test_row_test

    # product test with :pending state should need reloading
    assert_equal true, should_reload_measure_test_row?(task)

    # product test with :ready state should not need reloading
    product_test.state = :ready
    product_test.save!
    assert_equal false, should_reload_measure_test_row?(task)

    # if task has a pending most recent execution then needs reloading
    execution = task.test_executions.create!(:state => :pending)
    assert_equal true, should_reload_measure_test_row?(task)

    # if task has a passing most recent execution then does not need reloading
    execution.state = :passed
    execution.save!
    assert_equal false, should_reload_measure_test_row?(task)

    # if execution has a sibling execution that is pending then needs reloading
    sibling_task = product_test.tasks.create!
    sibling_execution = sibling_task.test_executions.create!(:sibling_execution_id => execution.id, :state => :pending)
    execution.sibling_execution_id = sibling_execution.id
    execution.save!
    assert_equal true, should_reload_measure_test_row?(task)

    # if both executions are finished then does not need reloading
    sibling_execution.state = :failed
    sibling_execution.save!
    assert_equal false, should_reload_measure_test_row?(task)
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
    product = Product.new(vendor: Vendor.find('4f57a8791d41c851eb000002'), name: 'my product', c1_test: true, c2_test: true, bundle_id: '4fdb62e01d41c820f6000001',
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

  def test_each_tab_c1_only
    make_product_certify(@product, true, false, false, false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 1, test_types.count, 'should only have a manual entry tab'
    assert_equal 'C1 Manual', titles[0]
  end

  def test_each_tab_c1_c2
    make_product_certify(@product, true, true, false, false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 3, test_types.count, 'should have manual entry, c1 measure, and c2 measure tabs'
    assert_equal 'C1 Manual', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
    assert_equal 'C2 (QRDA-III)', titles[2]
  end

  def test_each_tab_c1_c3
    make_product_certify(@product, true, false, true, false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 1, test_types.count, 'should only have manual entry tab'
    assert_equal 'C1 + C3 Manual', titles[0]
  end

  def test_each_tab_c1_c4
    make_product_certify(@product, true, false, false, true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 2, test_types.count, 'should have manual entry tab and filtering test tab'
    assert_equal 'C1 Manual', titles[0]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[1]
  end

  def test_each_tab_c1_c3_c4
    make_product_certify(@product, true, false, true, true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 2, test_types.count, 'should have manual entry tab and filtering test tab'
    assert_equal 'C1 + C3 Manual', titles[0]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[1]
  end

  def test_each_tab_c1_c2_c3
    make_product_certify(@product, true, true, true, false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 3, test_types.count, 'should have manual entry, c1 measure, and c2 measure tabs'
    assert_equal 'C1 + C3 Manual', titles[0]
    assert_equal 'C1 + C3 (QRDA-I)', titles[1]
    assert_equal 'C2 + C3 (QRDA-III)', titles[2]
  end

  def test_each_tab_c1_c2_c4
    make_product_certify(@product, true, true, false, true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 4, test_types.count, 'should have manual entry, c1 measure, c2 measure, and c4 filtering tabs'
    assert_equal 'C1 Manual', titles[0]
    assert_equal 'C1 (QRDA-I)', titles[1]
    assert_equal 'C2 (QRDA-III)', titles[2]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[3]
  end

  def test_each_tab_c1_c2_c3_c4
    make_product_certify(@product, true, true, true, true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 4, test_types.count, 'should have manual entry, c1 measure, c2 measure, and c4 filtering tabs'
    assert_equal 'C1 + C3 Manual', titles[0]
    assert_equal 'C1 + C3 (QRDA-I)', titles[1]
    assert_equal 'C2 + C3 (QRDA-III)', titles[2]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[3]
  end

  def test_each_tab_c2_only
    make_product_certify(@product, false, true, false, false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)

    assert_equal 1, test_types.count, 'should only have a c2 measure tab'
    assert_equal 'C2 (QRDA-III)', titles[0]
  end

  def test_each_tab_c2_c3
    make_product_certify(@product, false, true, true, false)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 1, test_types.count, 'should only have c2 measure tab'
    assert_equal 'C2 + C3 (QRDA-III)', titles[0]
  end

  def test_each_tab_c2_c4
    make_product_certify(@product, false, true, false, true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 2, test_types.count, 'should have c2 measure and c4 filtering tabs'
    assert_equal 'C2 (QRDA-III)', titles[0]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[1]
  end

  def test_each_tab_c2_c3_c4
    make_product_certify(@product, false, true, true, true)
    test_types, titles = get_test_types_titles_and_descriptions(@product)
    assert_equal 2, test_types.count, 'should have c2 measure and c4 filtering tabs'
    assert_equal 'C2 + C3 (QRDA-III)', titles[0]
    assert_equal 'C4 (QRDA-I and QRDA-III)', titles[1]
  end

  def get_test_types_titles_and_descriptions(product)
    test_types = []
    titles = []
    descriptions = []
    each_tab(product) do |test_type, title|
      test_types << test_type
      titles << title
      descriptions << descriptions
    end
    [test_types, titles, descriptions]
  end

  def make_product_certify(product, c1 = false, c2 = false, c3 = false, c4 = false)
    product.c1_test = c1
    product.c2_test = c2
    product.c3_test = c3
    product.c4_test = c4
    product.save!
    product.product_tests.checklist_tests.each(&:destroy) unless c1
    product.product_tests.measure_tests.each(&:destroy) unless c2
    product.product_tests.filtering_tests.each(&:destroy) unless c4
  end

  def test_title_for
    assert_equal 'C1 Manual', title_for(Product.new(c1: true), 'ChecklistTest')
    assert_equal 'C1 + C3 Manual', title_for(Product.new(c1_test: true, c3_test: true), 'ChecklistTest')

    assert_equal 'C1 (QRDA-I)', title_for(Product.new(c1_test: true), 'MeasureTest', true)
    assert_equal 'C1 + C3 (QRDA-I)', title_for(Product.new(c1_test: true, c3_test: true), 'MeasureTest', true)

    assert_equal 'C2 (QRDA-III)', title_for(Product.new(c2_test: true), 'MeasureTest', false)
    assert_equal 'C2 + C3 (QRDA-III)', title_for(Product.new(c2_test: true, c3_test: true), 'MeasureTest', false)

    assert_equal 'C4 (QRDA-I and QRDA-III)', title_for(Product.new(c4_test: true), 'FilteringTest')
  end

  def test_measure_test_tasks
    assert measure_test_tasks(@product, true).all? { |task| task._type == 'C1Task' }
    assert measure_test_tasks(@product, false).all? { |task| task._type == 'C2Task' }
  end
end
