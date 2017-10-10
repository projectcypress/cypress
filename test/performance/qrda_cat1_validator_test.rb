require 'test_helper'
require 'rails/performance_test_help'

class QrdaCat1ValidatorTest < ActionDispatch::PerformanceTest
  include ::Validators

  def setup
    collection_fixtures('bundles', 'measures')
    @bundle = Bundle.find('4fdb62e01d41c820f6000001')
    @measures = Measure.in(hqmf_id: ['8A4D92B2-397A-48D2-0139-7CC6B5B8011E'])
    @validator_with_c3 = QrdaCat1Validator.new(@bundle, false, true, @measures)
    @validator_without_c3 = QrdaCat1Validator.new(@bundle, false, false, @measures)
    @task = C1Task.new
  end

  def test_validate_good_file
    file = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good/0_Dental_Peds_A.xml')).read
    @validator_with_c3.validate(file, task: @task)
    assert_empty @validator_with_c3.errors

    @validator_without_c3.validate(file, task: @task)
    assert_empty @validator_without_c3.errors
  end
end
