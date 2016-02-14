require 'test_helper'
require 'pry'

class ChecklistTestTest < ActiveJob::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
    vendor = Vendor.create(name: 'test_vendor_name')
    @product = vendor.products.create(name: 'test_product', c1_test: true)
  end

  def test_create
    assert_enqueued_jobs 0
    pt = @product.product_tests.build({ name: 'test_for_measure_1a',
                                        measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'],
                                        bundle_id: '4fdb62e01d41c820f6000001' }, ChecklistTest)
    assert pt.valid?, 'product test should be valid with product, name, and measure_id'
    assert pt.checked_criteria? == false
    pt.create_checked_criteria
    assert pt.checked_criteria?
  end
end
