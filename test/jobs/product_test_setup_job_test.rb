require 'test_helper'

class ProductTestSetupJobTest < ActiveJob::TestCase
  def setup
    vendor = FactoryGirl.create(:vendor)
    @bundle = FactoryGirl.create(:static_bundle)
    @product = vendor.products.create(name: 'test_product', c2_test: true, randomize_records: true, bundle_id: @bundle.id,
                                       measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
  end

  def test_perform_with_measure_test_creates_provider
    test = @product.product_tests.build({ name: "my measure test #{rand}", measure_ids: @product.measure_ids }, MeasureTest)
    test.save!
    ProductTestSetupJob.perform_now(test)
    test.reload

    assert test.provider
  end
end
