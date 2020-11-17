require 'test_helper'
class MeasurePeriodValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = MeasurePeriodValidator.new
  end

  def test_file_with_good_mp
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_missing_measure.xml')).read
    @validator.validate(file)
    assert_empty @validator.errors
  end

  def test_file_without_mp_start
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_no_start.xml')).read
    @validator.validate(file)
    errors = @validator.errors
    assert_equal 'Document needs to report the Measurement Start Date', errors[0].message
  end

  def test_file_without_mp_end
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_no_end.xml')).read
    @validator.validate(file)
    errors = @validator.errors
    assert_equal 'Document needs to report the Measurement End Date', errors[0].message
  end
end
