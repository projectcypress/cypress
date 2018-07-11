require 'test_helper'
require 'rails/performance_test_help'

class CalculatingSmokingGunValidatorPerfTest < ActionDispatch::PerformanceTest
  def setup
    @test_execution = FactoryBot.create(:test_execution)
    @task = @test_execution.task
    @records = @task.patients
    @product_test = @task.product_test
    @validator = ::Validators::CalculatingSmokingGunValidator.new(@product_test.measures, @product_test.records, @product_test.id)
  end

  def test_denom
    # Instead of using a static xml file as part of our test suite, dynamically
    # generate a valid xml file on the fly and pass it directly thru to validation
    mes, sd, ed = Cypress::PatientZipper.mes_start_end(@records)
    test_record = @records.find_by(givenNames: ['Dental_Peds'])
    file = Cypress::QRDAExporter.new(mes, sd, ed).export(test_record)
    doc = @test_execution.build_document(file)
    @validator.validate(doc, 'task' => @task, 'test_execution' => @test_execution, :file_name => 'Dental_Peds_A')
    assert_empty @validator.errors
  end
end
