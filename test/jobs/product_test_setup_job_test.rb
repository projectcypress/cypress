require 'test_helper'

class ProductTestSetupJobTest < ActiveJob::TestCase
  def setup
    vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    @product = vendor.products.build(name: 'test_product', c2_test: true, randomize_patients: true, bundle_id: @bundle.id,
                                     measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
  end

  def test_perform_with_measure_test_creates_provider
    test = @product.product_tests.build({ name: "my measure test #{rand}", measure_ids: @product.measure_ids }, MeasureTest)
    ProductTestSetupJob.perform_now(test)
    @product.save!
    test.reload

    assert test.provider
  end
end
