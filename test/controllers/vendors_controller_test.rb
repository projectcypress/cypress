require 'test_helper'
class VendorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'users')
    sign_in User.first
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert assigns(:vendors)
  end

  test 'should get show' do
    get :show, id: Vendor.first.id
    assert_response :success
    assert assigns(:vendor)
    assert assigns(:products)
  end

  test 'should get new' do
    get :new
    assert_response :success
    assert assigns(:vendor)
  end
end
