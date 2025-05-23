# frozen_string_literal: true

require 'test_helper'
class ExpectedResultsValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @product_test = FactoryBot.create(:product_test_static_result)
    @validator = ExpectedResultsValidator.new(@product_test.expected_results, @product_test.bundle.randomization)
    @vendor_user = FactoryBot.create(:vendor_user)
    # For this test, any measure will work
    @measure = Measure.first
    @task = C2Task.new
    @task.product_test = @product_test
    setup_augmented_patients
  end

  def setup_augmented_patients
    @patient1 = ProductTestPatient.create(givenNames: ['Jill'], familyName: 'Mcguire', medical_record_number: '198718e0-4d42-0135-8680-12999b0ed66f')
    CQM::IndividualResult.create(IPP: 1, patient_id: @patient1.id, patient: @patient1, measure: @measure)
    @augmented_patient1 = { 'original_patient_id' => @patient1.id, 'medical_record_number' => '198718e0-4d42-0135-8680-12999b0ed66f',
                            'first' => %w[Jill J], 'last' => %w[Mcguire Mcguirn], :gender => %w[F M] }

    @patient2 = ProductTestPatient.create(givenNames: ['Ivan'], familyName: 'Mcguire', medical_record_number: '098718e0-4d42-0135-8680-12999b0ed66f')
    CQM::IndividualResult.create(IPP: 1, patient_id: @patient2.id, patient: @patient2, measure: @measure)
    @augmented_patient2 = { 'original_patient_id' => @patient2.id, 'medical_record_number' => '098718e0-4d42-0135-8680-12999b0ed66f',
                            'first' => %w[Ivan Ivan], 'last' => %w[Mcguire Mcguirn], :gender => %w[M F] }

    @patient3 = ProductTestPatient.create(givenNames: ['Joe'], familyName: 'Mcguire', medical_record_number: '298718e0-4d42-0135-8680-12999b0ed66f')
    CQM::IndividualResult.create(IPP: 1, patient_id: @patient3.id, patient: @patient3, measure: @measure)
    @augmented_patient3 = { 'original_patient_id' => @patient3.id, 'medical_record_number' => '298718e0-4d42-0135-8680-12999b0ed66f',
                            'first' => %w[Joe John], 'last' => %w[Mcguire Mcguirn], :gender => %w[M M] }
  end

  def test_validate_good_file
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good.xml')).read

    @validator.validate(file, 'task' => @task)
    assert_empty @validator.errors
  end

  def test_validate_file_with_incorrect_population_count
    modified_expected_results = @product_test.expected_results
    modified_expected_results['40280382-5FA6-FE85-0160-0918E74D2075']['PopulationCriteria1']['IPP'] = 0
    validator = ExpectedResultsValidator.new(modified_expected_results, @product_test.bundle.randomization)
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good.xml')).read

    validator.validate(file, 'task' => @task)
    assert_equal 1, (validator.errors.count { |e| e.message == "Expected IPP value 0\n      does not match reported value 1" })
  end

  # Add in test for stratification
  # def test_validate_missing_stratifications
  #   file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_III/ep_test_qrda_cat3_missing_stratification.xml')).read
  #   @validator.validate(file, 'task' => @task)

  #   errors = @validator.errors
  #   assert_equal 11, errors.length, 'should error on missing stratifications' # 10 errors related to pop sums
  #   assert_equal 10, errors.count { |e| !pop_sum_err_regex.match(e.message).nil? }
  #   assert_equal 1, (errors.count do |e|
  #     !/\ACould not find value for stratification [a-zA-Z\d\-]{36}  for Population \w+\z/.match(e.message).nil?
  #   end), 'should error on missing stratifications'
  # end

  def test_validate_missing_supplemental_data
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_missing_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 2, errors.length, 'should error on missing supplemental data'
    errors.each { |e| (assert_equal :result_validation, e.validator_type) }
  end

  def test_validate_augmented_results_one_augmented_patient
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_extra_male.xml')).read
    @task.product_test.augmented_patients = [@augmented_patient1]
    @patient1.correlation_id = @task.product_test.id
    @patient1.save!
    @validator.validate(file, 'task' => @task)
    errors = @validator.errors

    assert_empty errors, 'should be no errors when changing the gender count in accordance with the augmented patients'
  end

  def test_validate_augmented_results_two_augmented_patients
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good.xml')).read
    @task.product_test.augmented_patients = [@augmented_patient1, @augmented_patient3]
    @patient1.correlation_id = @task.product_test.id
    @patient1.save!
    @patient3.correlation_id = @task.product_test.id
    @patient3.save!
    @validator.validate(file, 'task' => @task)
    errors = @validator.errors

    assert_equal @patient3.bundle.id, @task.product_test.bundle.id
    assert_empty errors, 'should be no errors when changing the gender count in accordance with the augmented patients'
  end

  def test_validate_augmented_results_three_augmented_patients_with_opposing_values
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good.xml')).read
    @task.product_test.augmented_patients = [@augmented_patient1, @augmented_patient2, @augmented_patient3]
    @patient1.correlation_id = @task.product_test.id
    @patient1.save!
    @patient2.correlation_id = @task.product_test.id
    @patient2.save!
    @patient3.correlation_id = @task.product_test.id
    @patient3.save!
    @validator.validate(file, 'task' => @task)
    errors = @validator.errors

    assert_empty errors, 'should be no errors when changing the gender count in accordance with the augmented patients'
  end

  def test_validate_augmented_results_three_augmented_patients_reporting_extra_male
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_missing_supplemental_two_extra_male.xml')).read
    @task.product_test.augmented_patients = [@augmented_patient1, @augmented_patient2, @augmented_patient3]
    @patient1.correlation_id = @task.product_test.id
    @patient1.save!
    @patient2.correlation_id = @task.product_test.id
    @patient2.save!
    @patient3.correlation_id = @task.product_test.id
    @patient3.save!
    @validator.validate(file, 'task' => @task)
    errors = @validator.errors

    error_details = { type: 'supplemental_data',
                      population_key: 'IPP',
                      population_id: 'EA122D3D-5348-43DB-96A5-2D044ACAAA4D',
                      data_type: 'SEX',
                      code: 'M',
                      expected_value: 0,
                      reported_value: 2 }

    # The should be error messages when reported value is outside of the expected range.  In this example, the range is 2-3.
    assert_equal 1, (errors.count { |e| e.validator_type == :result_validation && e.error_details == error_details })
  end

  def test_validate_extra_data
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_extra_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors
    assert_equal 1, (errors.count { |e| e.message == 'supplemental data error' })
  end

  def pop_sum_err_regex
    /\AReported \w+ [a-zA-Z\d-]{36} value \d+ does not match sum \d+ of supplemental key \w+ values\z/
  end
end
