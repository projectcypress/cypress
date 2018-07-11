require 'test_helper'
require 'rails/performance_test_help'

class QrdaCat1ValidatorPerfTest < ActionDispatch::PerformanceTest
  include ::Validators

  def setup
    @test_execution = FactoryBot.create(:test_execution)
    @task = @test_execution.task
    @records = @task.patients
    @bundle = @task.bundle
    @measures = @task.product_test.measures
    mes, sd, ed = Cypress::PatientZipper.mes_start_end(@records)
    test_record = @records.find_by(firstNames: ['Dental_Peds'])
    file = Cypress::QRDAExporter.new(mes, sd, ed).export(test_record)
    @doc = @test_execution.build_document(file)
  end

  def test_validate_good_file_with_c3
    @validator = QrdaCat1Validator.new(@bundle, false, true, @measures)
    @validator.validate(@doc, task: @task)
    assert_empty @validator.errors
  end

  def test_validate_good_file_without_c3
    @validator = QrdaCat1Validator.new(@bundle, false, false, @measures)
    @validator.validate(@doc, task: @task)
    assert_empty @validator.errors
  end
end
