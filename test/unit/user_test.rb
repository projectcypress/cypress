require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do

    collection_fixtures('users', '_id')
  end

  test "Shouldn't be able to submit a user with a short password" do
    u = User.first
    u.password = 'abcdefg'
    assert_not u.save
  end

  test "Shouldn't be able to submit a user with a password that's not complex enough" do
    u = User.first
    u.password = "NoNumsabc"
    assert_not u.save
    u.password = "nocapitals1"
    assert_not u.save
    u.password = "1234567!%"
    assert_not u.save
  end

  test "Should save a password that's complex enough" do
    u = User.first
    u.password = "ABC123!@"
    assert u.save
    u.password = "abc123!@"
    assert u.save
    u.password = "ABCabc123"
    assert u.save
  end

  test "shouldn't save someone where the password is the same as their email" do
    u = User.first
    u.password = u.email
    assert_not u.save
  end
end