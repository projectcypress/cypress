require 'test_helper'

class ProductTestSetupJobTest < ActiveJob::TestCase
  def setup
    collection_fixtures('bundles', 'measures')
    vendor = Vendor.new(name: "my vendor #{rand}")
    vendor.save!
    @product = vendor.products.build(name: "my product #{rand}", measure_ids: ['8A4D92B2-397A-48D2-0139-C648B33D5582'],
                                     bundle_id: '4fdb62e01d41c820f6000001')
  end

  def test_perform_with_measure_test_creates_provider
    test = @product.product_tests.build({ name: "my measure test #{rand}", measure_ids: @product.measure_ids }, MeasureTest)
    test.save!
    ProductTestSetupJob.perform_now(test)
    test.reload

    assert test.provider
  end
end
