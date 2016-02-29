require 'test_helper'
class TasksControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'users', 'roles')
    @vendor = Vendor.find(EHR1)
    @first_product = @vendor.products.first
    @first_test = @first_product.product_tests.first
    @first_task = @first_test.tasks.first
  end

  test 'should get index' do
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :index, product_test_id: @first_test.id
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:tasks)
    end
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to index for unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :index, product_test_id: @first_test.id
      assert_response 401, "#{@user.email} should have not access "
    end
  end

  test 'should get show' do
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR]) do
      get :show, id: @first_task.id
      assert_response :success, "#{@user.email} should have access "
      assert_not_nil assigns(:task)
    end
  end
  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to show for unauthorized users ' do
    for_each_logged_in_user([OTHER_VENDOR]) do
      get :show, id: @first_task.id
      assert_response 401, "#{@user.email} should not  have access "
    end
  end
end
