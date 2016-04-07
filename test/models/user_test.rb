require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def test_user_can_be_associated_with_poc
    APP_CONFIG['auto_associate_pocs'] = true
    Vendor.all.destroy
    v = Vendor.new(name: 'test_vendor_name')
    p = PointOfContact.new(name: 'test_poc_name', email: 'vendor@test.com')
    p.vendor = v
    assert v.save!
    assert p.user.nil?, 'POC should not have a user'
    u = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    assert u.has_role?(:vendor, v), 'User should be assocaited with the vendor'
    assert_equal u, p.user, 'Point of contact should be equal to created user'
  end

  def test_user_cannot_be_associated_with_poc_if_turned_off
    APP_CONFIG['auto_associate_pocs'] = false
    Vendor.all.destroy
    v = Vendor.new(name: 'test_vendor_name')
    p = PointOfContact.new(name: 'test_poc_name', email: 'vendor@test.com')
    p.vendor = v
    assert v.save!
    assert p.user.nil?, 'POC should not have a user'
    u = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    assert !u.has_role?(:vendor, v), 'User should not be assocaited with the vendor'
  end
end
