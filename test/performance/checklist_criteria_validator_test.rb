require 'test_helper'
require 'rails/performance_test_help'

class ChecklistCriteriaValidatorPerfTest < ActionDispatch::PerformanceTest
  def setup
    perf_test_collection_fixtures('bundles', 'health_data_standards_svs_value_sets', 'measures', 'patient_cache', 'product_tests', 'products',
                                  'providers', 'records', 'tasks', 'test_executions', 'vendors')
    @product_test = ProductTest.find('59a02432e5f131039c0aa44f')
    @test_execution = TestExecution.find('59a03b1ee5f131039c0aa45c')
    @task = Task.find('59a02433e5f131039c0aa455')
  end

  # Can't seem to verify that this validator fails no matter what is passed in
  def test_checklist_criteria_validator
    @checklist_validator = ::Validators::ChecklistCriteriaValidator.new(@product_test)
    file_name = 'test/fixtures/qrda/perf_test/4_FOUR_N_STROKE.xml'
    file = File.new(File.join(Rails.root, file_name)).read
    doc = @test_execution.build_document(file)
    @checklist_validator.validate(doc)
  end

end
