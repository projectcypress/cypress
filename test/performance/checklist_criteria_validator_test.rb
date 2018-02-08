require 'test_helper'
require 'rails/performance_test_help'

# CANNOT BE DONE UNTIL WE HAVE A ProductTest of _type ChecklistTest

class ChecklistCriteriaValidatorPerfTest < ActionDispatch::PerformanceTest
  def setup
    @product = FactoryGirl.create(:product_static_bundle)
    @product.add_checklist_test
    @checklist_test = @product.product_tests.checklist_tests.first
    @validator = ::Validators::ChecklistCriteriaValidator.new(@checklist_test)
  end

  # Can't seem to verify that this validator fails no matter what is passed in
  def test_checklist_criteria_validator
    # Instead of using a static xml file as part of our test suite, dynamically
    # generate a valid xml file on the fly and pass it directly thru to validation
    mes, sd, ed = Cypress::PatientZipper::mes_start_end(@records)
    test_record = @records.find_by(first: 'Dental_Peds')
    file = Cypress::QRDAExporter.new(mes, sd, ed).export(test_record)
    doc = @test_execution.build_document(file)
    @checklist_validator.validate(doc)
    binding.pry
  end

end
