require 'test_helper'
require 'rails/performance_test_help'

class ProviderValidatorTest < ActionDispatch::PerformanceTest
  def setup
    collection_fixtures('bundles', 'product_tests', 'products', 'tasks', 'test_executions')
    @validator = ::Validators::MeasurePeriodValidator.new
    @test_execution = TestExecution.find('4f5900981d41c851eb000482')
  end

  def test_file_with_good_mp
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_measure.xml')).read

    @test_execution.task.bundle.measure_period_start = Time.new(2015, 01, 01).utc.to_i
    @test_execution.task.bundle.effective_date = Time.new(2015, 12, 31).utc.to_i
    @validator.validate(file, 'test_execution' => @test_execution)
    assert_empty @validator.errors
  end

  def test_file_with_bad_mp
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_bad_mp.xml')).read
    @test_execution.task.bundle.measure_period_start = Time.new(2015, 01, 01).utc.to_i
    @test_execution.task.bundle.effective_date = Time.new(2015, 12, 31).utc.to_i
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors

    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
    assert_equal 'Reported Measurement Period should start on 20150101', errors[0].message
    assert_equal 'Reported Measurement Period should end on 20151231', errors[1].message
  end
end
