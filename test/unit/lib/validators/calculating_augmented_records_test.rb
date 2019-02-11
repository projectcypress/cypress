require 'test_helper'
class CalculatingAugmentedRecordsTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @product_test = FactoryBot.create(:product_test_static_result)
    @validator = ::Validators::CalculatingAugmentedRecords.new(@product_test.measures, [], @product_test.id)
  end

  def test_validation_of_clone
    patient = @product_test.patients.first
    cloned_patient = patient.clone
    assert @validator.validate_calculated_results(cloned_patient, effective_date: @product_test.effective_date, orig_product_patient: patient)
  end

  def test_validation_of_bad_clone
    patient = @product_test.patients.first
    cloned_patient = patient.clone
    cloned_patient.qdmPatient = nil
    assert_equal false, @validator.validate_calculated_results(cloned_patient, effective_date: @product_test.effective_date, orig_product_patient: patient)
  end

  def test_validation_of_clone_with_modified_name
    patient = @product_test.patients.first
    cloned_patient = patient.clone
    cloned_patient.familyName = 'Changed'
    assert @validator.validate_calculated_results(cloned_patient, effective_date: @product_test.effective_date, orig_product_patient: patient)
  end
end
