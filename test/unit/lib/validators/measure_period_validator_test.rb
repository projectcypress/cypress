require 'test_helper'
class MeasurePeriodValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    collection_fixtures('bundles', 'product_tests', 'products', 'tasks', 'test_executions')
    @validator = MeasurePeriodValidator.new
    @test_execution = TestExecution.find('4f5900981d41c851eb000482')
  end

  def test_file_with_good_mp
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_missing_measure.xml')).read

    # measure_period_start and effective dates are set using milliseconds (below are for 2015)
    @test_execution.task.bundle.measure_period_start = 1_420_070_400
    @test_execution.task.bundle.effective_date = 1_451_606_399
    @validator.validate(file, 'test_execution' => @test_execution)
    assert_empty @validator.errors
  end

  def test_file_with_unshifted_mp_for_shifted_product_test
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_missing_measure.xml')).read

    @test_execution.task.product_test.product.shift_records = true
    # measure_period_start and effective dates are set using milliseconds (below are for 2015)
    @test_execution.task.bundle.measure_period_start = 1_420_070_400
    @test_execution.task.bundle.effective_date = 1_451_606_399
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors
    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
  end

  def test_file_with_shifted_mp_for_shifted_product_test
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_dates_shifted.xml')).read

    @test_execution.task.product_test.product.shift_records = true
    # measure_period_start and effective dates are set using milliseconds (below are for 2015)
    @test_execution.task.bundle.measure_period_start = 1_420_070_400
    @test_execution.task.bundle.effective_date = 1_451_606_399
    @validator.validate(file, 'test_execution' => @test_execution)

    assert_empty @validator.errors
  end

  def test_file_with_bad_mp
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'ep_test_qrda_cat3_bad_mp.xml')).read
    # measure_period_start and effective dates are set using milliseconds (below are for 2015)
    @test_execution.task.bundle.measure_period_start = 1_420_070_400
    @test_execution.task.bundle.effective_date = 1_451_606_399
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors

    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
    assert_equal 'Reported Measurement Period should start on 20150101', errors[0].message
    assert_equal 'Reported Measurement Period should end on 20151231', errors[1].message
  end
end
