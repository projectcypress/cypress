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
    assert_empty @validator.errors
  end

  def test_validate_good_qrda_1_1_file
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_good_1_1.xml')).read
    @task.bundle.version = '2016.0.0'
    @validator.validate(file, 'task' => @task)
    assert_empty @validator.errors
  end

  def test_validate_bad_qrda_1_1_file
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_1_1_not_ipop.xml')).read
    @task.bundle.version = '2016.0.0'
    @validator.validate(file, 'task' => @task)
    assert_equal 'Could not find value for Population IPOP', @validator.errors[0].message
    assert_equal 24, @validator.errors.length, 'should error on missing measure entry'
  end

  def test_validate_missing_stratifications
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_stratification.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors

    assert_equal 1, errors.length, 'should error on missing stratifications'
    assert_match(/\ACould not find value for stratification [a-zA-Z\d\-]{36}  for Population \w+\z/, errors[0].message)
  end

  def test_validate_missing_supplemental_data
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors

    assert_equal 3, errors.length, 'should error on missing supplemental data'
    errors.each do |e|
      assert_equal :result_validation, e.validator_type
      assert_equal 'supplemental data error', e.message
    end
  end

  def test_validate_extra_data
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_extra_supplemental.xml')).read
    @validator.validate(file, 'task' => @task)

    errors = @validator.errors

    assert_equal 1, errors.length, 'should error on additional supplemental data'
    assert_equal 'supplemental data error', errors[0].message
  end
end
