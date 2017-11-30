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
    setup_augmented_records
  end

  def setup_augmented_records
    @augmented_record1 = { 'medical_record_number' => '098718e0-4d42-0135-8680-12999b0ed66f',
                           'first' => %w[Ivan Ivan], 'last' => %w[Mcguire Mcguirn], 'gender' => %w[M F] }
    @record1 = Record.new(first: 'Ivan', last: 'Mcguire', medical_record_number: '098718e0-4d42-0135-8680-12999b0ed66f')
    pc1 = HealthDataStandards::CQM::PatientCache.new(value: { 'IPP' => 1.000000, 'patient_id' => @record1.id })
    pc1.save!
    @record1.save!

    @augmented_record2 = { 'medical_record_number' => '198718e0-4d42-0135-8680-12999b0ed66f',
                           'first' => %w[Jill J], 'last' => %w[Mcguire Mcguirn], 'gender' => %w[F M] }
    @record2 = Record.new(first: 'Jill', last: 'Mcguire', medical_record_number: '198718e0-4d42-0135-8680-12999b0ed66f')
    pc2 = HealthDataStandards::CQM::PatientCache.new(value: { 'IPP' => 1.000000, 'patient_id' => @record2.id })
    pc2.save!
    @record2.save!

    @augmented_record3 = { 'medical_record_number' => '298718e0-4d42-0135-8680-12999b0ed66f',
                           'first' => %w[Joe John], 'last' => %w[Mcguire Mcguirn], 'gender' => %w[M M] }
    @record3 = Record.new(first: 'Joe', last: 'Mcguire', medical_record_number: '298718e0-4d42-0135-8680-12999b0ed66f')
    pc3 = HealthDataStandards::CQM::PatientCache.new(value: { 'IPP' => 1.000000, 'patient_id' => @record3.id })
    pc3.save!
    @record3.save!
  end

  def test_validate_good_file
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_good.xml')).read

    @validator.validate(file, 'task' => @task)
    assert_equal 10, @validator.errors.length # 10 errors related to pop sums
    assert_equal 10, @validator.errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
  end

  def test_validate_good_qrda_1_1_file
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_good_1_1.xml')).read
    @task.bundle.version = '2016.0.0'
    @validator.validate(file, 'task' => @task)
    assert_equal 10, @validator.errors.length # 10 errors related to pop sums
    assert_equal 10, @validator.errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
  end

  def test_validate_bad_qrda_1_1_file
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_1_1_not_ipop.xml')).read
    @task.bundle.version = '2016.0.0'
    @validator.validate(file, 'task' => @task)
    assert_equal 43, @validator.errors.length, 'should error on missing measure entry' # 7 errors related to pop sums
    assert_equal 19, @validator.errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 3, @validator.errors.count { |e| e.message == 'Could not find value for Population IPOP' }
  end

  def test_validate_missing_stratifications
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_missing_stratification.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 11, errors.length, 'should error on missing stratifications' # 10 errors related to pop sums
    assert_equal 10, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 1, (errors.count do |e|
      !/\ACould not find value for stratification [a-zA-Z\d\-]{36}  for Population \w+\z/.match(e.message).nil?
    end), 'should error on missing stratifications'
  end

  def test_validate_missing_supplemental_data
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_missing_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 16, errors.length, 'should error on missing supplemental data' # 13 errors related to pop sums
    errors.each { |e| (assert_equal :result_validation, e.validator_type) }
    assert_equal 13, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 3, errors.count { |e| e.validator_type == :result_validation && e.message == 'supplemental data error' }
  end

  def test_validate_augmented_results_one_augmented_patient
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_missing_supplemental_extra_female.xml')).read
    @task.product_test.augmented_records = [@augmented_record1]
    @record1.test_id = @task.product_test.id
    @record1.save!
    @validator.validate(file, 'task' => @task)
    errors = @validator.errors
    # Note: the 16 errors here are the same as the test_validate_missing_supplemental_data test (we are using the same task)
    # The importance here is that no new errors are introduced when changing the gender count in accordance with the augmented records
    assert_equal 16, errors.length, 'should error on missing supplemental data' # 13 errors related to pop sums
    errors.each { |e| (assert_equal :result_validation, e.validator_type) }
    assert_equal 13, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 3, errors.count { |e| e.validator_type == :result_validation && e.message == 'supplemental data error' }
  end

  def test_validate_augmented_results_two_augmented_patients
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_missing_supplemental_extra_female.xml')).read
    @task.product_test.augmented_records = [@augmented_record1, @augmented_record3]
    @record1.test_id = @task.product_test.id
    @record1.save!
    @record3.test_id = @task.product_test.id
    @record3.save!
    @validator.validate(file, 'task' => @task)
    errors = @validator.errors
    # Note: the 16 errors here are the same as the test_validate_missing_supplemental_data test (we are using the same task)
    # The importance here is that no new errors are introduced when changing the gender count in accordance with the augmented records
    assert_equal 16, errors.length, 'should error on missing supplemental data' # 13 errors related to pop sums
    errors.each { |e| (assert_equal :result_validation, e.validator_type) }
    assert_equal 13, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 3, errors.count { |e| e.validator_type == :result_validation && e.message == 'supplemental data error' }
  end

  def test_validate_augmented_results_three_augmented_patients_with_opposing_values
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_missing_supplemental_extra_male.xml')).read
    @task.product_test.augmented_records = [@augmented_record1, @augmented_record2, @augmented_record3]
    @record1.test_id = @task.product_test.id
    @record1.save!
    @record2.test_id = @task.product_test.id
    @record2.save!
    @record3.test_id = @task.product_test.id
    @record3.save!
    @validator.validate(file, 'task' => @task)
    errors = @validator.errors
    # Note: the 16 errors here are the same as the test_validate_missing_supplemental_data test (we are using the same task)
    # The importance here is that no new errors are introduced when changing the gender count in accordance with the augmented records
    assert_equal 16, errors.length, 'should error on missing supplemental data' # 13 errors related to pop sums
    errors.each { |e| (assert_equal :result_validation, e.validator_type) }
    assert_equal 13, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
    assert_equal 3, errors.count { |e| e.validator_type == :result_validation && e.message == 'supplemental data error' }
  end

  def test_validate_augmented_results_three_augmented_patients_reporting_extra_male
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_missing_supplemental_two_extra_male.xml')).read
    @task.product_test.augmented_records = [@augmented_record1, @augmented_record2, @augmented_record3]
    @record1.test_id = @task.product_test.id
    @record1.save!
    @record2.test_id = @task.product_test.id
    @record2.save!
    @record3.test_id = @task.product_test.id
    @record3.save!
    @validator.validate(file, 'task' => @task)
    errors = @validator.errors

    error_details = { type: 'supplemental_data',
                      population_key: 'IPP',
                      population_id: 'E83A6DA6-D34E-4107-8431-2FB2C86738C7',
                      data_type: 'SEX',
                      code: 'F',
                      expected_value: 3,
                      reported_value: 1 }

    # The should be error messages when reported value is outside of the expected range.  In this example, the range is 2-3.
    assert_equal 3, errors.count { |e| e.validator_type == :result_validation && e.error_details == error_details }
  end

  def test_validate_extra_data
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_extra_supplemental.xml')).read
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
