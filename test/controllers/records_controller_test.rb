require 'test_helper'
class RecordsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    FactoryBot.create(:admin_user)
    FactoryBot.create(:atl_user)
    FactoryBot.create(:user_user)
    vendor_user = FactoryBot.create(:vendor_user)
    FactoryBot.create(:other_user)
    @product_test = FactoryBot.create(:product_test_static_result)
    @patient_id = @product_test.bundle.patients.first.id
    @bundle = @product_test.bundle

    add_user_to_vendor(vendor_user, @product_test.product.vendor)
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
      get :index, params: { bundle_id: @bundle.id }
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:patients)
      assert assigns(:source)
      assert assigns(:bundle)
    end
  end

  test 'should get show' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :show, params: { id: @bundle.patients.find(@patient_id) }
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:record)
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to product test records unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      task_id = @product_test.tasks.first.id
      get :index, params: { task_id: task_id }
      assert_response 401
    end
  end
end
