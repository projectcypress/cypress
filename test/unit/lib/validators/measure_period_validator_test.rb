require 'test_helper'
class MeasurePeriodValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = MeasurePeriodValidator.new
  end

  def test_file_with_good_mp
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_measure.xml')).read

    @validator.validate(file)
    assert_empty @validator.errors
  end

  def test_file_with_bad_mp
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_bad_mp.xml')).read
    @validator.validate(file)
    errors = @validator.errors

    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
    assert_equal 'Reported Measurement Period should start on 20150101', errors[0].message
    assert_equal 'Reported Measurement Period should end on 20151231', errors[1].message
  end
end
