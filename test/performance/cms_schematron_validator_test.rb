require 'test_helper'
require 'rails/performance_test_help'

class CMSSchematronValidatorPerfTest < ActionDispatch::PerformanceTest
  def setup
    perf_test_collection_fixtures('bundles', 'health_data_standards_svs_value_sets', 'measures', 'patient_cache', 'product_tests', 'products',
                                  'providers', 'records', 'tasks', 'test_executions', 'vendors')
    @product_test = ProductTest.find('59a02432e5f131039c0aa448')
    @test_execution = TestExecution.find('59a03b1ee5f131039c0aa45c')
    @task = Task.find('59a02432e5f131039c0aa44c')
  end

  def test_hqr
    @hqr_validator = ::Validators::CMSQRDA1HQRSchematronValidator.new(@product_test.bundle.version)
    file_name = 'test/fixtures/qrda/perf_test/4_FOUR_N_STROKE.xml'
    file = File.new(File.join(Rails.root, file_name)).read
    doc = @test_execution.build_document(file)
    @hqr_validator.validate(doc, 'task' => @task, 'test_execution' => @test_execution, validate_reporting: @product_test.product.c3_test,
                                 :file_name => file_name)
    assert_equal 1, @hqr_validator.errors.length # 1 error related to UTC
  end

  def test_qrda3
    @qrda3_validator = ::Validators::CMSQRDA3SchematronValidator.new(@product_test.bundle.version)
    file_name = 'test/fixtures/qrda/perf_test/CMS71v6_QRDA3.xml'
    file = File.new(File.join(Rails.root, file_name)).read
    doc = @test_execution.build_document(file)
    @qrda3_validator.validate(doc, 'task' => @task, 'test_execution' => @test_execution, validate_reporting: @product_test.product.c3_test,
                                 :file_name => file_name)
    assert_equal 8, @qrda3_validator.errors.length
  end

  # Tests for PQRSSchematronValidator not implemented since they are extremely similar to the hqr and qrda3
  # tests, and due to the fact that the 2016 bundle we are using does not support PQRS validators
end
