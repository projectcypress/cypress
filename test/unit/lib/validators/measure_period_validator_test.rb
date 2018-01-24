require 'test_helper'
class MeasurePeriodValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = MeasurePeriodValidator.new
    @test_execution = FactoryGirl.create(:test_execution)
  end

  def test_file_with_good_mp
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_III/ep_test_qrda_cat3_good.xml')).read
    @validator.validate(file, 'test_execution' => @test_execution)
    assert_empty @validator.errors
  end

  def test_file_with_unshifted_mp_for_shifted_product_test
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_III/ep_test_qrda_cat3_good.xml')).read

    @test_execution.task.product_test.product.shift_records = true
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors
    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
  end

  def test_file_with_shifted_mp_for_shifted_product_test
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_III/ep_test_qrda_cat3_shifted.xml')).read

    @test_execution.task.product_test.product.shift_records = true
    @validator.validate(file, 'test_execution' => @test_execution)

    assert_empty @validator.errors
  end

  def test_file_with_bad_mp
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_III/ep_test_qrda_cat3_shifted.xml')).read
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors

    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
    assert_equal 'Reported Measurement Period should start on 20160101', errors[0].message
    assert_equal 'Reported Measurement Period should end on 20161231', errors[1].message
  end
end
