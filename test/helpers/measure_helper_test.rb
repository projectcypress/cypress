require 'test_helper'

class MeasureHelperTest < ActiveSupport::TestCase
  def setup
    collection_fixtures('measures', 'bundles')

    @cpc_and_diag_msrs = ['40280381-4600-425F-0146-1F8D3B750FAC']
    @cpc_msrs = ['40280381-4BE2-53B3-014C-0F589C1A1C39']
    @diag_msrs = ['8A4D92B2-397A-48D2-0139-7CC6B5B8011E', '8A4D92B2-3946-CDAE-0139-7944ACB700BD']
    @other_measures = ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD', '8A4D92B2-3887-5DF3-0139-0D01C6626E46']

    @bundle = Bundle.find('4fdb62e01d41c820f6000001')
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
