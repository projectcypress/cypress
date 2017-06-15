require 'test_helper'
class ExpectedResultsValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @product_test = ProductTest.find('51703a6a3054cf8439000044')
    @validator = ExpectedResultsValidator.new(@product_test.expected_results)
    @task = C2Task.new
    @task.product_test = @product_test
  end

  def test_validate_good_file
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_good.xml')).read

    @validator.validate(file, 'task' => @task)
    assert_equal 10, @validator.errors.length # 10 errors related to pop sums
    assert_equal 10, @validator.errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
  end

  def test_validate_good_qrda_1_1_file
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_good_1_1.xml')).read
    @task.bundle.version = '2016.0.0'
    @validator.validate(file, 'task' => @task)
    assert_equal 10, @validator.errors.length # 10 errors related to pop sums
    assert_equal 10, @validator.errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
  end

  def test_validate_bad_qrda_1_1_file
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_1_1_not_ipop.xml')).read
    @task.bundle.version = '2016.0.0'
    @validator.validate(file, 'task' => @task)
    assert_equal 43, @validator.errors.length, 'should error on missing measure entry' # 7 errors related to pop sums
    assert_equal 19, @validator.errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 3, @validator.errors.count { |e| e.message == 'Could not find value for Population IPOP' }
  end

  def test_validate_missing_stratifications
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_stratification.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 11, errors.length, 'should error on missing stratifications' # 10 errors related to pop sums
    assert_equal 10, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 1, (errors.count do |e|
      !/\ACould not find value for stratification [a-zA-Z\d\-]{36}  for Population \w+\z/.match(e.message).nil?
    end), 'should error on missing stratifications'
  end

  def test_validate_missing_supplemental_data
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 16, errors.length, 'should error on missing supplemental data' # 13 errors related to pop sums
    errors.each { |e| (assert_equal :result_validation, e.validator_type) }
    assert_equal 13, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 3, errors.count { |e| e.validator_type == :result_validation && e.message == 'supplemental data error' }
  end

  def test_validate_extra_data
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_extra_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 12, errors.length, 'should error on additional supplemental data' # 11 errors related to pop sums
    assert_equal 11, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 1, errors.count { |e| e.message == 'supplemental data error' }
  end

  def pop_sum_err_regex
    /\AReported \w+ [a-zA-Z\d\-]{36} value \d+ does not match sum \d+ of supplemental key \w+ values\z/
  end
end
