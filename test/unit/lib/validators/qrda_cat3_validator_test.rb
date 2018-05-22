require 'test_helper'
class QrdaCat3ValidatorTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    @product_test = FactoryBot.create(:product_test_static_result)

    @validator_with_c3 = QrdaCat3Validator.new(@product_test.expected_results, true, true, true, @product_test.bundle)
    @validator_without_c3 = QrdaCat3Validator.new(@product_test.expected_results, false, false, true, @product_test.bundle)
  end

  def test_validate_good_file
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good.xml')).read

    @validator_with_c3.validate(file)
    assert_empty @validator_with_c3.errors

    @validator_without_c3.validate(file)
    assert_empty @validator_without_c3.errors
  end
end
