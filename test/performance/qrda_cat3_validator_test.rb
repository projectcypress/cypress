require 'test_helper'
require 'rails/performance_test_help'

class QrdaCat3ValidatorPerfTest < ActionDispatch::PerformanceTest
  include ::Validators

  def setup
    @product_test = FactoryGirl.create(:product_test_static_result)
    @file = File.new(Rails.root.join('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_good.xml')).read
  end

  def test_validate_good_file_with_c3
    @validator = QrdaCat3Validator.new(@product_test.expected_results, true, true, true, @product_test.bundle)
    @validator.validate(@file)
    assert_empty @validator.errors
  end

  def test_validate_good_file_without_c3
    @validator = QrdaCat3Validator.new(@product_test.expected_results, false, false, true, @product_test.bundle)
    @validator.validate(@file)
    assert_empty @validator.errors
  end
end
