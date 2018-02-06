require 'test_helper'

class MeasureHelperTest < ActiveSupport::TestCase
  def setup
    APP_CONSTANTS['CPC_measures'] = { '2016' => ['53e3f13d-e5cf-445f-8dda-3720aff84011','53e3f13d-e5cf-445f-8dda-3720aff84012'] }
    @bundle = FactoryGirl.create(:static_bundle)
    @cpc_and_diag_msrs = ['53e3f13d-e5cf-445f-8dda-3720aff84011']
    @cpc_msrs = ['53e3f13d-e5cf-445f-8dda-3720aff84012']
    @diag_msrs = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    @other_measures = ['53e3f13d-e5cf-445f-8dda-3720aff84015', '53e3f13d-e5cf-445f-8dda-3720aff84016']
  end

  def test_cpc_and_diagnosis_measures
    selected_measures = @cpc_and_diag_msrs + @cpc_msrs + @diag_msrs + @other_measures

    measure = ApplicationController.helpers.pick_measure_for_filtering_test(selected_measures, @bundle)

    assert_only_in_correct_set measure.hqmf_id, @cpc_and_diag_msrs, @cpc_msrs + @diag_msrs + @other_measures
  end

  def test_cpc_only_measures
    selected_measures = @cpc_msrs + @diag_msrs + @other_measures

    measure = ApplicationController.helpers.pick_measure_for_filtering_test(selected_measures, @bundle)

    assert_only_in_correct_set measure.hqmf_id, @cpc_msrs, @diag_msrs + @other_measures
  end

  def test_diagnosis_only_measures
    selected_measures = @diag_msrs + @other_measures

    measure = ApplicationController.helpers.pick_measure_for_filtering_test(selected_measures, @bundle)

    assert_only_in_correct_set measure.hqmf_id, @diag_msrs, @other_measures
  end

  def test_not_cpc_or_diagnosis_measures
    selected_measures = @other_measures

    measure = ApplicationController.helpers.pick_measure_for_filtering_test(selected_measures, @bundle)

    assert_only_in_correct_set measure.hqmf_id, @other_measures
  end

  def assert_only_in_correct_set(item, correct, incorrect = [])
    assert item
    assert correct.include?(item)
    assert !incorrect.include?(item)
  end

  def test_should_reload_measure_test
    test = ProductTest.new(:name => 'my product test', :state => :not_ready)
    assert ApplicationController.helpers.should_reload_measure_test?(test)

    # product tests with no test executions should not be reloaded
    test.state = :ready
    assert !ApplicationController.helpers.should_reload_measure_test?(test)
    test.tasks.build
    assert !ApplicationController.helpers.should_reload_measure_test?(test)

    # product tests with test executions that are passing or failing should not be reloaded
    test = product_test_with_test_execution_with_state(:failing)
    assert !ApplicationController.helpers.should_reload_measure_test?(test)
    test = product_test_with_test_execution_with_state(:passing)
    assert !ApplicationController.helpers.should_reload_measure_test?(test)

    # product tests with test executions that are pending should be reloaded
    test = product_test_with_test_execution_with_state(:pending)
    assert ApplicationController.helpers.should_reload_measure_test?(test)
  end

  def product_test_with_test_execution_with_state(state)
    test = ProductTest.new(:state => :ready)
    task = test.tasks.build
    task.test_executions.build(state: state)
    test
  end
end
