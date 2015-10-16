require 'test_helper'

class ProducTest < MiniTest::Test

  def setup
    @vendor = Vendor.new(name: "test_vendor_name")
    @vendor.save
  end

  def after_teardown
    Product.all.destroy
    Vendor.all.destroy
  end

  def test_create
    pt = Product.new({vendor: @vendor, name: "test_product"})
    assert pt.valid?, "record should be valid"
    assert pt.save, "Should be able to create and save a Product"
  end

  def test_create_from_vendor
    pt = @vendor.products.build({name: "test_product"})
    assert pt.valid?, "record should be valid"
    assert pt.save, "Should be able to create and save a Product"
  end

  def test_must_have_name
    pt = Product.new({vendor: @vendor})
    assert_equal false,  pt.valid?, "record should not be valid"
    saved = pt.save
    assert_equal false, saved, "Should not be able to save without a name"
  end

  def test_must_have_vendor
    pt = Product.new({name:  "test_product"})
    assert_equal false,  pt.valid?, "record should not be valid"
    saved = pt.save
    assert_equal false, saved, "Should not be able to save without a vendor"
  end

end