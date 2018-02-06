require 'test_helper'
class QrdaCat1ValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @bundle = FactoryGirl.create(:static_bundle)
    @measures = [Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first]
    @validator_with_c3 = QrdaCat1Validator.new(@bundle, true, true, false, @measures)
    @validator_without_c3 = QrdaCat1Validator.new(@bundle, false, false, false, @measures)
    @task = C1Task.new
  end

  def test_validate_good_file
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_I/sample_patient_good.xml')).read
    @validator_with_c3.validate(file, task: @task)
    assert_empty @validator_with_c3.errors

    @validator_without_c3.validate(file, task: @task)
    assert_empty @validator_without_c3.errors
  end

  def test_validate_too_much_data_error
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_I/sample_patient_too_much_data.xml')).read
    @validator_with_c3.validate(file, task: @task)
    errors = @validator_with_c3.errors
    assert_not_empty errors
    errors.each do |e|
      assert_equal :warning, e.msg_type, 'All validation messages for too much data are always warnings'
    end

    @validator_without_c3.validate(file, task: @task)
    errors_no_c3 = @validator_without_c3.errors
    assert_empty errors_no_c3, 'When C3 is not selected, too much data is not evaluated'
  end

  def test_bad_schema
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_I/sample_patient_bad_schema.xml')).read
    @validator_with_c3.validate(file, task: @task)

    errors = @validator_with_c3.errors
    assert_not_empty errors
    errors.each do |e|
      assert_equal :error, e.msg_type, 'All validation messages should be errors for a bad schema'
    end
  end
end
