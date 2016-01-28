require 'test_helper'
class RecordsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'records', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures')
    sign_in User.first
  end

  test 'should get index no scoping' do
    get :index
    assert_response :success
    assert assigns(:records)
    assert assigns(:source)
    assert assigns(:bundle)
  end

  test 'should get index scoped to bundle' do
    get :index, bundle_id: Bundle.where(:records.exists => true).first
    assert_response :success
    assert assigns(:records)
    assert assigns(:source)
    assert assigns(:bundle)
  end

  test 'should get index scoped to product_test' do
    get :index, product_test_id: ProductTest.first
    assert_response :success
    assert assigns(:records)
    assert assigns(:source)
    assert assigns(:product_test)
  end

  test 'should get show' do
    get :show, id: Bundle.where(:records.exists => true).first.records.first
    assert_response :success
    assert assigns(:record)
  end
end
