require 'test_helper'
class TasksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'users')
    sign_in User.first
  end

  test 'should get index' do
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    get :index, product_test_id: ProductTest.first.id
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  test 'should get show' do
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    get :show, id: Task.first.id
    assert_response :success
    assert_not_nil assigns(:task)
  end

  test 'should get edit page' do
    # do this for admin,atl,user:owner -- need negative tests for non
    # access users
    get :edit, id: Task.first.id
    assert_response :success
    assert_not_nil assigns(:task)
  end

  test 'should get new page' do
    # do this for admin,atl,user:owner  -- need negative tests for non
    # access users
    get :new, type: 'Task', product_test_id: ProductTest.first.id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_not_nil assigns(:product_test)
  end

  test 'should be able to delete task' do
    # do this for admin,atl,user:owner  -- need negative tests for non
    # access users
    id = Task.first.id
    delete :destroy, id: id
    assert_response 204
    assert_equal nil, Task.where(_id: id).first, 'Should have deleted task'
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to index for unauthorized users ' do

  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to show for unauthorized users ' do

  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to new for  unauthorized users ' do

  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to delete unauthorized users ' do

  end

end
