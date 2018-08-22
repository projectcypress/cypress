require 'test_helper'

class VendorsHelperTest < ActiveJob::TestCase
  include VendorsHelper
  include ProductsHelper

  def setup
    drop_database
    product_test = FactoryBot.create(:product_test_static_result)
    @bundle = product_test.bundle
    @vendor = product_test.product.vendor
    @product = Product.new(vendor: @vendor.id, name: 'test_product', c1_test: true, c2_test: true, c3_test: true, c4_test: true,
                           bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    setup_checklist_test
    setup_measure_tests
    setup_filtering_tests
  end

  def setup_checklist_test
    checklist_test = @product.product_tests.build({ name: 'c1 visual',
                                                    measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
    checklist_test.save!
    checked_criterias = []
    measures = Measure.top_level.where(:hqmf_id.in => checklist_test.measure_ids, :bundle_id => @product.bundle_id)
    measures.each do |measure|
      # chose criteria randomly
      criterias = measure['source_data_criteria'].sort_by { rand }[0..4]
      criterias.each do |criteria_key, _criteria_value|
        checked_criterias.push(measure_id: measure.id.to_s, source_data_criteria: criteria_key, completed: false)
      end
    end
    checklist_test.checked_criteria = checked_criterias
    checklist_test.save!
    checklist_test.tasks.create!({}, C1ChecklistTask)
    checklist_test.tasks.create!({}, C3ChecklistTask)
  end

  def setup_measure_tests
    @product.product_tests.build({ name: 'test_product_test_name_1',
                                   measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest).save!
    @product.product_tests.build({ name: 'test_product_test_name_2',
                                   measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest).save!
    @product.product_tests.measure_tests.each do |test|
      test.tasks.build({}, C1Task)
      test.tasks.build({}, C2Task)
      test.tasks.build({}, C3Cat1Task)
      test.tasks.build({}, C3Cat3Task)
    end
  end

  # one C1 failing test, one C3 passing test
  def setup_cat1_measure_executions
    c1_cat1_execution = @product.product_tests.measure_tests.find_by(name: 'test_product_test_name_2').tasks.c1_task.test_executions.build(:state => :failed)
    c3_cat1_execution = @product.product_tests.measure_tests.find_by(:name => 'test_product_test_name_2').tasks.c3_cat1_task.test_executions.build(:state => :passed)
    c1_cat1_execution.sibling_execution_id = c3_cat1_execution.id
    c1_cat1_execution.save
    c3_cat1_execution.save
  end

  # one C2 passing test, one C3 failing test
  def setup_cat3_measure_executions
    c2_cat3_execution = @product.product_tests.measure_tests.find_by(:name => 'test_product_test_name_2').tasks.c2_task.test_executions.build(:state => :passed)
    c3_cat3_execution = @product.product_tests.measure_tests.find_by(:name => 'test_product_test_name_2').tasks.c3_cat3_task.test_executions.build(:state => :failed)
    c2_cat3_execution.sibling_execution_id = c3_cat3_execution.id
    c2_cat3_execution.save
    c3_cat3_execution.save
  end

  def setup_filtering_tests
    @product.product_tests.create!({ :name => 'Filter Test 1', :cms_id => 'SomeCMSID', :measure_ids => ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                     :options => { :filters => { :filt1 => ['val1'], :filt2 => ['val2'] } } }, FilteringTest)
    @product.product_tests.filtering_tests.each do |test|
      test.tasks.build({}, Cat1FilterTask)
      test.tasks.build({}, Cat3FilterTask)
    end

    # one cat1 passing execution, one cat3 failing execution
    @product.product_tests.filtering_tests.find_by(:name => 'Filter Test 1').cat1_task.test_executions.create(:state => :passed)
    @product.product_tests.filtering_tests.find_by(:name => 'Filter Test 1').cat3_task.test_executions.create(:state => :passed)
  end

  # # # # # # # # #
  #   T E S T S   #
  # # # # # # # # #

  def test_get_product_status_values
    setup_cat1_measure_executions
    setup_cat3_measure_executions
    certs = get_product_status_values(@product)
    assert_c1(certs.C1)
    assert_c2(certs.C2)
    assert_c3(certs.C3)
    assert_c4(certs.C4)
  end

  def assert_c1(cert)
    assert_equal 0, cert['Checklist'].passing
    assert_equal 0, cert['Checklist'].failing
    assert_equal 1, cert['Checklist'].not_started
    assert_equal 1, cert['Checklist'].total

    assert_equal 0, cert['QRDA Category I'].passing
    assert_equal 1, cert['QRDA Category I'].failing
    assert_equal 1, cert['QRDA Category I'].not_started
    assert_equal 2, cert['QRDA Category I'].total
  end

  def assert_c2(cert)
    assert_equal 1, cert['QRDA Category III'].passing
    assert_equal 0, cert['QRDA Category III'].failing
    assert_equal 1, cert['QRDA Category III'].not_started
    assert_equal 2, cert['QRDA Category III'].total
  end

  def assert_c3(cert)
    assert_equal 1, cert['QRDA Category I'].passing
    assert_equal 0, cert['QRDA Category I'].failing
    assert_equal 1, cert['QRDA Category I'].not_started
    assert_equal 2, cert['QRDA Category I'].total

    assert_equal 0, cert['QRDA Category III'].passing
    assert_equal 1, cert['QRDA Category III'].failing
    assert_equal 1, cert['QRDA Category III'].not_started
    assert_equal 2, cert['QRDA Category III'].total
  end

  def assert_c4(cert)
    assert_equal 1, cert['QRDA Category I'].passing
    assert_equal 0, cert['QRDA Category I'].failing
    assert_equal 0, cert['QRDA Category I'].not_started
    assert_equal 1, cert['QRDA Category I'].total

    assert_equal 1, cert['QRDA Category III'].passing
    assert_equal 0, cert['QRDA Category III'].failing
    assert_equal 0, cert['QRDA Category III'].not_started
    assert_equal 1, cert['QRDA Category III'].total
  end

  def test_vendor_statuses
    setup_cat1_measure_executions
    setup_cat3_measure_executions
    vendor_status = vendor_statuses(@product.vendor)

    assert_equal 0, vendor_status['passing']
    assert_equal 0, vendor_status['errored']
    assert_equal 1, vendor_status['failing']
    assert_equal 1, vendor_status['incomplete']
    assert_equal 2, vendor_status['total']
  end

  def test_status_to_css_classes
    assert_equal 'status-passing', status_to_css_classes('passing')['cell']
    assert_equal 'check', status_to_css_classes('passing')['icon']
    assert_equal 'fas', status_to_css_classes('passing')['type']
    assert_equal 'text-success', status_to_css_classes('passing')['text']
    assert_equal 'status-failing', status_to_css_classes('failing')['cell']
    assert_equal 'times', status_to_css_classes('failing')['icon']
    assert_equal 'fas', status_to_css_classes('failing')['type']
    assert_equal 'text-danger', status_to_css_classes('failing')['text']
    assert_equal 'status-not-started', status_to_css_classes('not_started')['cell']
    assert_equal 'circle', status_to_css_classes('not_started')['icon']
    assert_equal 'far', status_to_css_classes('not_started')['type']
    assert_equal 'text-info', status_to_css_classes('not_started')['text']
    assert_equal 'exclamation', status_to_css_classes('errored')['icon']
    assert_equal 'fas', status_to_css_classes('errored')['type']
    assert_equal 'status-errored', status_to_css_classes('errored')['cell']
    assert_equal 'text-warning', status_to_css_classes('errored')['text']
  end

  def test_checklist_status_vals_not_started
    test = @product.product_tests.checklist_tests.find_by(:name => 'c1 visual')
    passing, failing, errored, not_started, total = checklist_status_vals(test, 'C1')

    assert_equal 0, passing
    assert_equal 0, failing
    assert_equal 0, errored
    assert_equal 1, not_started
    assert_equal 1, total
  end

  def test_checklist_status_vals_failing
    test = @product.product_tests.checklist_tests.first
    test.checked_criteria.first.code_complete = true
    test.checked_criteria.first.code = '123'
    test.checked_criteria.first.passed_qrda = true
    passing, failing, errored, not_started, total = checklist_status_vals(test, 'C1')

    assert_equal 0, passing
    assert_equal 1, failing
    assert_equal 0, errored
    assert_equal 0, not_started
    assert_equal 1, total
  end

  def test_checklist_status_vals_passing
    test = @product.product_tests.checklist_tests.find_by(:name => 'c1 visual')
    test.checked_criteria.each do |criteria|
      criteria.code_complete = true
      criteria.code = '123'
      criteria.passed_qrda = true
    end
    passing, failing, errored, not_started, total = checklist_status_vals(test, 'C1')

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 0, errored
    assert_equal 0, not_started
    assert_equal 1, total
  end

  def test_product_test_statuses_not_started
    passing, failing, errored, not_started, total = product_test_statuses(@product.product_tests.measure_tests, 'C1Task')

    assert_equal 0, passing
    assert_equal 0, failing
    assert_equal 0, errored
    assert_equal total, not_started
  end

  # returns [checklist_test, c1_checklist_task, c3_checklist_task]
  def setup_checklist_status_vals_for_execution
    assert_equal 1, @product.product_tests.checklist_tests.count
    test = @product.product_tests.checklist_tests.first
    [test, test.tasks.c1_checklist_task, test.tasks.c3_checklist_task]
  end

  def test_checklist_status_vals_for_execution_both_executions_passing
    test, c1_task, c3_task = setup_checklist_status_vals_for_execution
    c1_task.test_executions.create!(:state => :passed, :_id => '12345', :sibling_execution_id => '54321')
    c3_task.test_executions.create!(:state => :passed, :_id => '54321', :sibling_execution_id => '12345')
    assert_equal [1, 0, 0, 0, 1], checklist_status_vals_for_execution(test, 'C1')
  end

  def test_checklist_status_vals_for_test_execution_one_execution_failing_one_passing
    test, c1_task, c3_task = setup_checklist_status_vals_for_execution
    c1_task.test_executions.create!(:state => :passed, :_id => '12345', :sibling_execution_id => '54321')
    c3_task.test_executions.create!(:state => :failed, :_id => '54321', :sibling_execution_id => '12345')
    assert_equal [0, 1, 0, 0, 1], checklist_status_vals_for_execution(test, 'C1')
  end

  def test_checklist_status_vals_for_test_execution_one_execution_pending_one_passing
    test, c1_task, c3_task = setup_checklist_status_vals_for_execution
    c1_task.test_executions.create!(:state => :passed, :_id => '12345', :sibling_execution_id => '54321')
    c3_task.test_executions.create!(:state => :pending, :_id => '54321', :sibling_execution_id => '12345')
    assert_equal [0, 0, 0, 1, 1], checklist_status_vals_for_execution(test, 'C1')
  end

  def test_checklist_status_vals_for_test_execution_one_execution_errored_one_passing
    test, c1_task, c3_task = setup_checklist_status_vals_for_execution
    c1_task.test_executions.create!(:state => :passed, :_id => '12345', :sibling_execution_id => '54321')
    c3_task.test_executions.create!(:state => :errored, :_id => '54321', :sibling_execution_id => '12345')
    assert_equal [0, 0, 1, 0, 1], checklist_status_vals_for_execution(test, 'C1')
  end

  # pending executions should take precedence over failing executions
  def test_checklist_status_vals_for_test_execution_one_execution_pending_one_failing
    test, c1_task, c3_task = setup_checklist_status_vals_for_execution
    c1_task.test_executions.create!(:state => :failed, :_id => '12345', :sibling_execution_id => '54321')
    c3_task.test_executions.create!(:state => :pending, :_id => '54321', :sibling_execution_id => '12345')
    assert_equal [0, 0, 0, 1, 1], checklist_status_vals_for_execution(test, 'C1')
  end

  # failing executions should take precedence over errored executions
  def test_checklist_status_vals_for_test_execution_one_execution_errored_one_failing
    test, c1_task, c3_task = setup_checklist_status_vals_for_execution
    c1_task.test_executions.create!(:state => :errored, :_id => '12345', :sibling_execution_id => '54321')
    c3_task.test_executions.create!(:state => :failed, :_id => '54321', :sibling_execution_id => '12345')
    assert_equal [0, 1, 0, 0, 1], checklist_status_vals_for_execution(test, 'C1')
  end

  def test_checklist_status_vals_with_checklist_status_vals_for_test_execution
    assert_equal 1, @product.product_tests.checklist_tests.count
    test = @product.product_tests.checklist_tests.first
    # make all passed
    test.checked_criteria.each do |criteria|
      criteria.code_complete = true
      criteria.code = '123'
      criteria.passed_qrda = true
    end

    assert_equal [1, 0, 0, 0, 1], checklist_status_vals(test, 'C1')

    # add test executions that are failing
    test.tasks.c1_checklist_task.test_executions.create!(:state => :failed, :_id => '12345', :sibling_execution_id => '54321')
    test.tasks.c3_checklist_task.test_executions.create!(:state => :failed, :_id => '54321', :sibling_execution_id => '12345')
    assert_equal [1, 1, 0, 0, 2], checklist_status_vals(test, 'C1')
  end

  def test_product_test_statuses_passing
    tests = @product.product_tests.measure_tests
    tests.find_by(:name => 'test_product_test_name_2').tasks.where(:_type => 'C1Task').first.test_executions.build(:state => :passed).save
    passing, failing, errored, not_started, total = product_test_statuses(tests, 'C1Task')

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 0, errored
    assert_equal 1, not_started
    assert_equal 2, total
  end

  def test_product_test_statuses_failing
    tests = @product.product_tests.measure_tests
    tests.find_by(:name => 'test_product_test_name_2').tasks.where(:_type => 'C1Task').first.test_executions.build(:state => :failed).save
    passing, failing, errored, not_started, total = product_test_statuses(tests, 'C1Task')

    assert_equal 0, passing
    assert_equal 1, failing
    assert_equal 0, errored
    assert_equal 1, not_started
    assert_equal 2, total
  end

  def test_product_test_statuses_errored
    tests = @product.product_tests.measure_tests
    tests.first.tasks.where(:_type => 'C1Task').first.test_executions.build(:state => :errored).save
    passing, failing, errored, not_started, total = product_test_statuses(tests, 'C1Task')

    assert_equal 0, passing
    assert_equal 0, failing
    assert_equal 1, errored
    assert_equal 1, not_started
    assert_equal 2, total
  end

  def test_product_test_statuses_cat1
    tests = @product.product_tests.measure_tests
    c1_execution = tests.find_by(:name => 'test_product_test_name_2').tasks.where(:_type => 'C1Task').first.test_executions.build(:state => :failed)
    c3_execution = tests.find_by(:name => 'test_product_test_name_2').tasks.where(:_type => 'C3Cat1Task').first.test_executions.build(:state => :passed)
    c1_execution.sibling_execution_id = c3_execution.id
    c1_execution.save
    c3_execution.save
    passing, failing, errored, _, total = product_test_statuses(tests, 'C3Cat1Task')

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 1, passing
    assert_equal 0, errored
    assert_equal 2, total
  end

  def test_product_test_statuses_cat1_errored
    tests = @product.product_tests.measure_tests
    c1_execution = tests.first.tasks.where(:_type => 'C1Task').first.test_executions.build(:state => :passed)
    c3_execution = tests.first.tasks.where(:_type => 'C3Cat1Task').first.test_executions.build(:state => :errored)
    c1_execution.sibling_execution_id = c3_execution.id
    c1_execution.save
    c3_execution.save
    passing, failing, errored, _, total = product_test_statuses(tests, 'C3Cat1Task')

    assert_equal 0, failing
    assert_equal 0, passing
    assert_equal 1, errored
    assert_equal 2, total
  end

  def test_product_test_statuses_cat3
    tests = @product.product_tests.measure_tests
    c2_execution = tests.find_by(:name => 'test_product_test_name_2').tasks.where(:_type => 'C2Task').first.test_executions.build(:state => :failed)
    c3_execution = tests.find_by(:name => 'test_product_test_name_2').tasks.where(:_type => 'C3Cat3Task').first.test_executions.build(:state => :passed)
    c2_execution.sibling_execution_id = c3_execution.id
    c2_execution.save
    c3_execution.save
    passing, failing, errored, _, total = product_test_statuses(tests, 'C3Cat3Task')

    assert_equal 1, passing
    assert_equal 0, failing
    assert_equal 1, passing
    assert_equal 0, errored
    assert_equal 2, total
  end

  def test_product_test_statuses_cat3_errored
    tests = @product.product_tests.measure_tests
    c2_execution = tests.first.tasks.where(:_type => 'C2Task').first.test_executions.build(:state => :failed)
    c3_execution = tests.first.tasks.where(:_type => 'C3Cat3Task').first.test_executions.build(:state => :errored)
    c2_execution.sibling_execution_id = c3_execution.id
    c2_execution.save
    c3_execution.save
    passing, failing, errored, _, total = product_test_statuses(tests, 'C3Cat3Task')

    assert_equal 0, passing
    assert_equal 0, failing
    assert_equal 1, errored
    assert_equal 2, total
  end

  def test_get_product_status_values_performs_caching
    assert_equal false, Rails.cache.exist?("#{@product.cache_key}/status_values"), 'cache key for product should not exist before function call'

    # cache key exists after call
    get_product_status_values(@product)
    assert Rails.cache.exist?("#{@product.cache_key}/status_values"), 'cache key for product should exist after get_product_status_values call'
  end

  def test_cache_key_changes_after_tests
    get_product_status_values(@product)
    assert_changes_cache_key do |product|
      checklist_test = product.product_tests.checklist_tests.find_by(:name => 'c1 visual')
      checklist_test.checked_criteria.first.completed = true
      checklist_test.save
    end
    assert_changes_cache_key { |product| product.product_tests.measure_tests.find_by(:name => 'test_product_test_name_2').tasks.c1_task.test_executions.create({}) }
    assert_changes_cache_key { |product| product.product_tests.filtering_tests.find_by(:name => 'Filter Test 1').tasks.cat1_filter_task.test_executions.create({}) }
  end

  def assert_changes_cache_key
    old_cache_key = "#{@product.cache_key}/status_values"
    yield @product
    @product.reload
    assert_not_equal old_cache_key, "#{@product.cache_key}/status_values"
  end
end
