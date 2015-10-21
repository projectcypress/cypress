require 'test_helper'

class ProductTestTest < MiniTest::Test
  def setup
    vendor = Vendor.create(name: 'test_vendor_name')
    @product = vendor.products.create(name: 'test_product')
  end

  def after_teardown
    Vendor.all.destroy
  end

  def test_create
    pt = @product.product_tests.build(name: 'test_for_measure_1a', measure_id: '1a')
    assert pt.valid?, 'product test should be valid with product, name and measure'
    assert pt.save, 'should be able to save valid product test'
  end

  def test_must_have_name
    pt = @product.product_tests.build(measure_id: '1a')
    assert_equal false,  pt.valid?, 'product test should not be valid without a name'
    assert_equal false,  pt.save, 'should not be able to save product test without a name'
  end

  def test_must_have_measure_id
    pt = @product.product_tests.build(name: 'test_for_measure_1a')
    assert_equal false,  pt.valid?, 'product test should not be valid without a measure_id'
    assert_equal false,  pt.save, 'should not be able to save product test without a measure_id'
  end

  def test_must_have_product
    pt = ProductTest.new(name: 'test_for_measure_1a', measure_id: '1a')
    assert_equal false,  pt.valid?, 'product test should not be valid without a product'
    assert_equal false,  pt.save, 'should not be able to save product test without a product'
  end
end
