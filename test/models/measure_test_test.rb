require 'test_helper'
class MeasureTestTest < MiniTest::Test
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
    vendor = Vendor.create!(name: 'test_vendor_name')
    @product = vendor.products.create(name: 'test_product')
  end

  def teardown
    drop_database
  end

  def test_more_than_one_measure
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: %w(0001 0002) }, MeasureTest)
    assert_equal false,  pt.valid?, 'product test should not be valid without a '
    assert_equal false,  pt.save, 'should not be able to save product test with more than 1 measure id'
    errors = pt.errors
    assert errors.key?(:measure_ids)
  end

  def test_single_measure
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    assert_equal true,  pt.valid?, 'product test should be valid with single measure id'
    assert_equal true,  pt.save, 'should save with single measure id'
  end
end
