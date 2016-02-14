require 'test_helper'
class RecordsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'records', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures')
    sign_in User.first
  end

  test 'should get index no scoping' do
    # do this for all users
    get :index
    assert_response :success
    assert assigns(:records)
    assert assigns(:source)
    assert assigns(:bundle)
  end

  test 'should get index scoped to bundle' do
    # do this for all users
    get :index, bundle_id: Bundle.where(:records.exists => true).first
    assert_response :success
    assert assigns(:records)
    assert assigns(:source)
    assert assigns(:bundle)
  end

  test 'should get index scoped to product_test' do
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    get :index, product_test_id: ProductTest.first
    assert_response :success
    assert assigns(:records)
    assert assigns(:source)
    assert assigns(:product_test)
  end


  test 'should get index scoped to task' do
    # do this for admin,atl,user:owner and vendor -- need negative tests for non
    # access users
    get :index, task_id: Task.first
    assert_response :success
    assert assigns(:records)
    assert assigns(:source)
    assert assigns(:task)
  end


  test 'should get show' do
    # do this for all users
    get :show, id: Bundle.where(:records.exists => true).first.records.first
    assert_response :success
    assert assigns(:record)
  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to product test records unauthorized users ' do

  end

  # need negative tests for user that does not have owner or vendor access
  test 'should be able to restrict access to task records for unauthorized users ' do

  end
end
