require 'test_helper'
class VendorsControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('vendors', 'products', 'users', 'roles')
  end

  test 'should get index' do
    for_each_logged_in_user([ADMIN, ATL, USER, VENDOR, OTHER_VENDOR]) do
      get :index
      assert_response :success
      assert assigns(:vendors)
    end
  end

  test 'should get show' do
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, id: Vendor.find(EHR1).id
      assert_response :success, "#{@user.email} should  have acces to vendor "
      assert assigns(:vendor)
      assert assigns(:products)
    end
  end

  test 'should restrict access to show' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, id: Vendor.find(EHR1).id
      assert_response 401, "#{@user.email} should not have acces to vendor "
    end
  end
  test 'should get new' do
    for_each_logged_in_user([ADMIN, ATL, USER]) do
      get :new
      assert_response :success
      assert assigns(:vendor)
    end
  end

  test 'should restrict access to  new' do
    for_each_logged_in_user([VENDOR, OTHER_VENDOR]) do
      get :new
      assert_response 401
    end
  end
end
