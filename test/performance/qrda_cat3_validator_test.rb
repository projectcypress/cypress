require 'test_helper'
require 'rails/performance_test_help'

class QrdaCat3ValidatorPerfTest < ActionDispatch::PerformanceTest
  include ::Validators

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @product_test = ProductTest.find('51703a6a3054cf8439000044')

    @validator_with_c3 = QrdaCat3Validator.new(@product_test.expected_results, true, true, true, @product_test.bundle)
    @validator_without_c3 = QrdaCat3Validator.new(@product_test.expected_results, false, false, true, @product_test.bundle)
  end

  def test_validate_good_file
    file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_good.xml')).read

    @validator_with_c3.validate(file)
    assert_empty @validator_with_c3.errors

    @validator_without_c3.validate(file)
    assert_empty @validator_without_c3.errors
  end
end
