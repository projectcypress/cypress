require 'test_helper'
require 'rails/performance_test_help'

class MeasurePeriodValidatorPerfTest < ActionDispatch::PerformanceTest
  def setup
    @validator = ::Validators::MeasurePeriodValidator.new
    @test_execution = FactoryGirl.create(:test_execution)
  end

  def test_file_with_good_mp
    file = File.new(Rails.root.join('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_good.xml')).read

    @validator.validate(file, 'test_execution' => @test_execution)
    assert_empty @validator.errors
  end

  def test_file_with_bad_mp
    file = File.new(Rails.root.join('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_bad_mp.xml')).read
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors

    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
    assert_equal 'Reported Measurement Period should start on 20160101', errors[0].message
    assert_equal 'Reported Measurement Period should end on 20161231', errors[1].message
  end
end
