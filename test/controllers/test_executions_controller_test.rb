require 'test_helper'
class TestExecutionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'tasks', 'test_executions', 'users')
    sign_in User.first
  end
  teardown do
    drop_database
  end
  test 'should get index' do
    get :index, task_id: Task.first.id
    assert_response :success
    assert_not_nil assigns(:test_executions)
  end

  test 'should get show' do
    get :show, id: TestExecution.first.id
    assert_response :success
    assert_not_nil assigns(:test_execution)
  end

  test 'should be able to delete test execution' do
    id = TestExecution.first.id
    delete :destroy, id: TestExecution.first.id
    assert_response 204
    assert_equal nil, TestExecution.where(_id: id).first, 'SHould have deleted test execution'
  end
end
