require 'test_helper'

class VendorTest < MiniTest::Test

  def after_teardown
    Vendor.all.destroy
  end

  def test_new_vendor_can_be_made
    assert Vendor.new(name: "test_vendor_name")
  end

  def test_vendor_can_be_created
    v = Vendor.new(name: "test_vendor_name")
    assert v.save!
  end

  def test_vendor_no_name_cannot_be_saved
    v = Vendor.new()
    assert_raises Mongoid::Errors::Validations do
      v.save!
    end
  end

  def test_vendor_same_name_cannot_be_saved
    name = "I have the same name!"
    v1 = Vendor.new(name: name)
    v2 = Vendor.new(name: name)
    v1.save!
    assert_raises Mongoid::Errors::Validations do
      v2.save!
    end
  end

  def test_vendor_with_poc_can_be_saved
    v = Vendor.new(name: "test_vendor_name")
    p = PointOfContact.new(name: "test_poc_name")
    p.vendor = v
    assert v.save!
  end

  def test_vendor_with_multiple_pocs_can_be_saved
    v = Vendor.new(name: "test_vendor_name")
    p1 = PointOfContact.new(name: "poc1")
    p2 = PointOfContact.new(name: "poc2")
    p1.vendor = v
    p2.vendor = v
    assert v.save!
  end

  def test_vendor_with_poc_with_no_name_cannot_be_saved
    v = Vendor.new(name: "test_vendor_name")
    p = PointOfContact.new()
    p.vendor = v
    assert_raises Mongoid::Errors::Validations do
      assert v.save!
    end
  end

  def test_vendor_with_pocs_with_same_name_cannot_be_saved
    poc_name = "I have the same name!"
    v = Vendor.new(name: "test_vendor_name")
    p1 = PointOfContact.new(name: name)
    p2 = PointOfContact.new(name: name)
    p1.vendor = v
    p2.vendor = v
    assert_raises Mongoid::Errors::Validations do
      assert v.save!
    end
  end

end
