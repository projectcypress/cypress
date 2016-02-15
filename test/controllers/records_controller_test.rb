require 'test_helper'
class RecordsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'records', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures', 'roles')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.first
  end

  test 'should get index no scoping' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :index
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:records)
      assert assigns(:source)
      assert assigns(:bundle)
    end
  end

  test 'should get index scoped to bundle' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :index, bundle_id: Bundle.where(:records.exists => true).first
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:records)
      assert assigns(:source)
      assert assigns(:bundle)
    end
  end



  test 'should get show' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :show, id: Bundle.where(:records.exists => true).first.records.first
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:record)
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to product test records unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, product_test_id: @first_product.product_tests.first.id
      assert_response 401
    end
  end
end
