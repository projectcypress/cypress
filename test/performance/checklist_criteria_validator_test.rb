require 'test_helper'
require 'rails/performance_test_help'

# CANNOT BE PROPERLY DONE UNTIL WE HAVE A ProductTest of _type ChecklistTest

class ChecklistCriteriaValidatorPerfTest < ActionDispatch::PerformanceTest
  def setup
    @test_execution = FactoryBot.create(:test_execution)
    @task = @test_execution.task
    @records = @task.patients
    @product = @task.product_test.product
    @checklist_test = @product.product_tests.checklist_tests.first
    criteria = @checklist_test.checked_criteria[0, 1]
    criteria[0].source_data_criteria = 'DiagnosisActivePregnancy'
    criteria[0].code = '210'
    criteria[0].code_complete = true
    criteria[0].attribute_code = '4896'
    criteria[0].attribute_complete = true
    criteria[0].result_complete = true
    criteria[0].passed_qrda = true
    @checklist_test.checked_criteria = criteria
    @checklist_test.save!
    @validator = ::Validators::ChecklistCriteriaValidator.new(@checklist_test)
  end

  def test_checklist_criteria_validator_correct_codes
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_correct_codes.zip'))

    Artifact.new(file: zip).each_file do |_name, file|
      doc = @test_execution.build_document(file)
      @validator.validate(doc)
      assert_equal @checklist_test.checked_criteria.collect(&:passed_qrda?), [true]
    end
  end

  def test_checklist_criteria_validator_incorrect_codes
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_incorrect_codes.zip'))

    Artifact.new(file: zip).each_file do |_name, file|
      doc = @test_execution.build_document(file)
      @validator.validate(doc)
      assert_equal @checklist_test.checked_criteria.collect(&:passed_qrda?), [false]
    end
  end
end
