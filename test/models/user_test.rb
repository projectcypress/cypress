require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def test_user_can_be_associated_with_poc
    APP_CONFIG['auto_associate_pocs'] = true
    Vendor.destroy_all
    v = Vendor.new(name: 'test_vendor_name')
    p = PointOfContact.new(name: 'test_poc_name', email: 'vendor@test.com')
    p.vendor = v
    assert v.save!
    assert p.user.nil?, 'POC should not have a user'
    u = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    assert u.user_role?(:vendor, v), 'User should be assocaited with the vendor'
    assert_equal u, p.user, 'Point of contact should be equal to created user'
  end

  def test_user_cannot_be_associated_with_poc_if_turned_off
    APP_CONFIG['auto_associate_pocs'] = false
    Vendor.destroy_all
    v = Vendor.new(name: 'test_vendor_name')
    p = PointOfContact.new(name: 'test_poc_name', email: 'vendor@test.com')
    p.vendor = v
    assert v.save!
    assert p.user.nil?, 'POC should not have a user'
    u = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    assert !u.user_role?(:vendor, v), 'User should not be assocaited with the vendor'
  end

  def test_assign_default_role
    Settings[:default_role] = :user
    u = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    assert u.user_role? :user
    assert u.user_role? 'user'

    Settings[:default_role] = nil
    u = User.create(email: 'vendor2@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    assert_empty u.roles, 'user should not have any roles assigned '
  end
end
