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
    pt = Product.new({vendor: @vendor, name: "test_product", ehr_type: "provider", c1_test: true})
    assert pt.valid?, "record should be valid"
    assert pt.save, "Should be able to create and save a Product"
  end

  def test_create_from_vendor
    pt = @vendor.products.build({name: "test_product", ehr_type: "provider", c1_test: true})
    assert pt.valid?, "record should be valid"
    assert pt.save, "Should be able to create and save a Product"
  end

  def test_must_have_name
    pt = Product.new({vendor: @vendor, ehr_type: "provider", c1_test: true})
    assert_equal false, pt.valid?, "record should not be valid"
    saved = pt.save
    assert_equal false, saved, "Should not be able to save without a name"
  end

  def test_must_have_vendor
    pt = Product.new({name: "test_product", ehr_type: "provider", c1_test: true})
    assert_equal false, pt.valid?, "record should not be valid"
    saved = pt.save
    assert_equal false, saved, "Should not be able to save without a vendor"
  end

  def test_must_have_ehr_type
    pt = Product.new({vendor: @vendor, name: "test_product", c1_test: true})
    assert_equal false, pt.valid?, "record should not be valid"
    saved = pt.save
    assert_equal false, saved, "Should not be able to save without an ehr_type"
  end

  def test_ehr_type_hospital_is_valid
    pt = Product.new({vendor: @vendor, name: "test_product", ehr_type: "hospital", c1_test: true})
    assert pt.valid?, "record should be valid"
    assert pt.save, "Should be able to save with ehr_type of hospital"
  end

  def test_invalid_ehr_type
    pt = Product.new({vendor: @vendor, name: "test_product", ehr_type: "other", c1_test: true})
    assert_equal false, pt.valid?, "record should not be valid"
    saved = pt.save
    assert_equal false, saved, "Should not be able to save with invalid ehr_type"
  end

  def test_must_have_at_least_one_certification_test_type
    pt = Product.new({vendor: @vendor, name: "test_product", ehr_type: "provider"})
    assert_equal false, pt.valid?, "record should not be valid"
    saved = pt.save
    assert_equal false, saved, "Should not be able to save without at least one certification type"
  end

  def test_can_have_multiple_certification_test_types
    pt = Product.new({vendor: @vendor, name: "test_product", ehr_type: "provider", c2_test: true, c4_test: true})
    assert pt.valid?, "record should be valid"
    assert pt.save, "Should be able to create and save with two certification types"
  end

end
