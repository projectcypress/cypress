require 'test_helper'
class RecordsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'records', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures', 'roles')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.where(name: 'Vendor 1 Product 1').find('4f57a88a1d41c851eb000004')
  end

  test 'should redirect from index to default bundle' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :index
      assert_redirected_to bundle_records_path(Bundle.default)
    end
  end

  test 'should not crash when no bundles' do
    Bundle.all.destroy
    for_each_logged_in_user([ADMIN]) do
      get :index
      assert_response :success
    end
  end

  test 'should get index scoped to bundle' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :index, bundle_id: Bundle.where(:records.exists => true).find('4fdb62e01d41c820f6000001')
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:records)
      assert assigns(:source)
      assert assigns(:bundle)
    end
  end

  test 'should get show' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :show, id: Bundle.where(:records.exists => true).find('4fdb62e01d41c820f6000001').records.find('4f5bb2ef1d41c841b3000589')
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:record)
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to product test records unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      task_id = @first_product.product_tests.where(name: 'vendor1 product1 test1').find('4f58f8de1d41c851eb000478').tasks.find('4f57a88a1d41c851eb000010')
      get :index, task_id: task_id
      assert_response 401
    end
  end
end
