require 'test_helper'
require 'rails/performance_test_help'

class ExpectedResultsValidatorPerfTest < ActionDispatch::PerformanceTest
  include ::Validators
  # self.profile_options = { runs: 1, metrics: [:wall_time, :process_time] }

  def setup
    @task = FactoryGirl.create(:task)
    @product_test = @task.product_test
    @validator = ExpectedResultsValidator.new(@product_test.expected_results)
  end

  def test_validate_good_file
    file = File.new(Rails.root.join('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_good.xml')).read
    @validator.validate(file, 'task' => @task)
    assert_empty @validator.errors
  end

  def test_validate_missing_supplemental_data
    file = File.new(Rails.root.join('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_missing_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 2, errors.length, 'should error on missing supplemental data'
    errors.each { |e| (assert_equal :result_validation, e.validator_type) }
    assert_equal 1, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
  end

  def test_validate_extra_data
    file = File.new(Rails.root.join('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_extra_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 2, errors.length, 'should error on additional supplemental data' # 11 errors related to pop sums
    assert_equal 1, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 1, errors.count { |e| e.message == 'supplemental data error' }
  end

  def pop_sum_err_regex
    /\AReported \w+ [a-zA-Z\d\-]{36} value \d+ does not match sum \d+ of supplemental key \w+ values\z/
  end
end
