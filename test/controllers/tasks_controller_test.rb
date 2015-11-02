require 'test_helper'
class TasksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'users')
    sign_in User.first
  end

  teardown do
    drop_database
  end

  test 'should get index' do
    get :index, product_test_id: ProductTest.first.id
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  test 'should get show' do
    get :show, id: Task.first.id
    assert_response :success
    assert_not_nil assigns(:task)
  end

  test 'should get edit page' do
    get :edit, id: Task.first.id
    assert_response :success
    assert_not_nil assigns(:task)
  end

  test 'should get new page' do
    get :new, type: 'Task', product_test_id: ProductTest.first.id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_not_nil assigns(:product_test)
  end

  test 'should be able to delete task' do
    id = Task.first.id
    delete :destroy, id: id
    assert_response 204
    assert_equal nil, Task.where(_id: id).first, 'Should have deleted task'
  end
end
