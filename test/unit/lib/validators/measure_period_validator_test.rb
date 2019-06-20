require 'test_helper'
class MeasurePeriodValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @validator = MeasurePeriodValidator.new
    @vendor_user = FactoryBot.create(:vendor_user)
    @test_execution = FactoryBot.build(:test_execution)
    @vendor_user.test_executions << @test_execution
  end

  def test_file_with_good_mp
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_missing_measure.xml')).read
    @validator.validate(file, 'test_execution' => @test_execution)
    assert_empty @validator.errors
  end

  def test_file_with_unshifted_mp_for_shifted_product_test
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_missing_measure.xml')).read

    @test_execution.task.product_test.product.shift_patients = true
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors
    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
  end

  def test_file_with_shifted_mp_for_shifted_product_test
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_shifted.xml')).read

    @test_execution.task.product_test.product.shift_patients = true
    @validator.validate(file, 'test_execution' => @test_execution)

    assert_empty @validator.errors
  end

  def test_file_without_mp_start
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_no_start.xml')).read

    @test_execution.task.product_test.product.shift_patients = true
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors
    assert_equal 'Document needs to report the Measurement Start Date', errors[0].message
  end

  def test_file_without_mp_end
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_no_end.xml')).read

    @test_execution.task.product_test.product.shift_patients = true
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors
    assert_equal 'Document needs to report the Measurement End Date', errors[0].message
  end

  def test_file_with_bad_mp
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_shifted.xml')).read
    @validator.validate(file, 'test_execution' => @test_execution)
    errors = @validator.errors

    assert_equal 2, errors.length, 'should have 2 errors for the invalid reporting period'
    assert_equal 'Reported Measurement Period should start on 20170101', errors[0].message
    assert_equal 'Reported Measurement Period should end on 20171231', errors[1].message
  end
end
