require 'test_helper'
require 'rails/performance_test_help'

class CMSSchematronValidatorTest < ActionDispatch::PerformanceTest
  def setup
    perf_test_collection_fixtures('bundles', 'health_data_standards_svs_value_sets', 'measures', 'patient_cache', 'product_tests', 'products',
                                  'providers', 'records', 'tasks', 'test_executions', 'vendors')
    @product_test = ProductTest.find('59a02432e5f131039c0aa448')
    @hqr_validator = ::Validators::CMSQRDA1HQRSchematronValidator.new(@product_test.bundle.version)
    @test_execution = TestExecution.find('59a03b1ee5f131039c0aa45c')
    @task = Task.find('59a02432e5f131039c0aa44c')
  end

  def test_hqr
    file_name = 'test/fixtures/qrda/perf_test/4_FOUR_N_STROKE.xml'
    file = File.new(File.join(Rails.root, file_name)).read
    doc = @test_execution.build_document(file)
    @hqr_validator.validate(doc, 'task' => @task, 'test_execution' => @test_execution, validate_reporting: @product_test.product.c3_test,
                                 :file_name => file_name)
  end
end
