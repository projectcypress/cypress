require 'test_helper'
require 'rails/performance_test_help'

class CMSSchematronValidatorPerfTest < ActionDispatch::PerformanceTest
  def setup
    @test_execution = FactoryBot.create(:test_execution)
    @task = @test_execution.task
    @records = @task.patients
    @product_test = @task.product_test
    mes, sd, ed = Cypress::PatientZipper.mes_start_end(@records)
    test_record = @records.find_by(firstNames: ['Dental_Peds'])
    file = Cypress::QRDAExporter.new(mes, sd, ed).export(test_record)
    @cat1_doc = @test_execution.build_document(file)
  end

  def test_hqr
    hqr_validator = ::Validators::CMSQRDA1HQRSchematronValidator.new(@product_test.bundle.version)
    hqr_validator.validate(@cat1_doc, 'task' => @task, 'test_execution' => @test_execution, validate_reporting: @product_test.product.c3_test,
                                      :file_name => 'Dental_Peds_A')
    assert_equal 5, hqr_validator.errors.count
  end

  def test_qrda3
    qrda3_validator = ::Validators::CMSQRDA3SchematronValidator.new(@product_test.bundle.version)
    c3c = Cypress::Cat3Calculator.new(@product_test.measure_ids, @product_test.bundle, @product_test.effective_date)
    c3c.import_cat1_file(@cat1_doc)
    qrda3_validator.validate(c3c.generate_cat3, 'task' => @task, 'test_execution' => @test_execution, validate_reporting: @product_test.product.c3_test,
                                                :file_name => 'CMS1234')
    assert_equal 8, qrda3_validator.errors.count
  end

  # Tests for PQRSSchematronValidator not implemented since they are extremely similar to the hqr and qrda3
  # tests, and due to the fact that the 2016 bundle we are using does not support PQRS validators
end
