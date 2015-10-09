require 'test_helper'

class VendorTest < MiniTest::Test
  def after_teardown
    Vendor.all.destroy
  end

  def test_true_is_true
    assert true
  end

  def test_vendor_can_be_built
    assert FactoryGirl.build(:vendor)
  end

  def test_vendor_with_pocs_can_be_built
    assert FactoryGirl.build(:vendor_with_pocs)
  end

  # ==================== #
  #   Validation Tests   #
  # ==================== #

  def test_vendor_can_be_saved
    assert FactoryGirl.create(:vendor)
  end

  def test_vendor_with_pocs_can_be_saved
    assert FactoryGirl.create(:vendor_with_pocs)
  end

  def test_vendor_with_no_name_cannot_be_saved
    assert_raises(Mongoid::Errors::Validations) { FactoryGirl.create(:vendor_no_name) }
  end

  def test_vendor_with_mil_name_cannot_be_saved
    assert_raises(Mongoid::Errors::Validations) { FactoryGirl.create(:vendor_nil_name) }
  end

  def test_vendors_with_same_name_cannot_be_saved
    FactoryGirl.create(:vendor_static_name)
    assert_raises(Mongoid::Errors::Validations) { FactoryGirl.create(:vendor_static_name) }
  end

  # with pocs

  def test_vendors_with_pocs_with_no_name_cannot_be_saved
    assert_raises(Mongoid::Errors::Validations) { FactoryGirl.create(:vendor_with_pocs_with_no_name) }
  end

  def test_vendors_with_pocs_with_same_name_cannot_be_saved
    assert_raises(Mongoid::Errors::Validations) { FactoryGirl.create(:vendor_with_pocs_same_name) }
  end

  # tests many vendors and many pocs. comment out these tests if you want testing to run faster

  def test_vendor_with_many_pocs
    assert FactoryGirl.create(:vendor_with_many_pocs)
  end

  def test_many_vendors
    all_valid = true
    (0..1000).each do
      all_valid &&= FactoryGirl.create(:vendor)
    end
    assert all_valid
  end

  # ====================== #
  #   Model Method Tests   #
  # ====================== #

  # no method tests yet since the vendor model has no methods
end
