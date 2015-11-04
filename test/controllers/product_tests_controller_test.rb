require 'test_helper'
class ProductTestsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'users')
    sign_in User.first
  end

  teardown do
    drop_database
  end
  test 'should get index' do
    get :index, product_id: Product.first.id
    assert_response :success
    assert_not_nil assigns(:product_tests)
    assert_not_nil assigns(:product)
  end

  test 'should get show' do
    get :show, id: ProductTest.first.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should get new' do
    get :new, product_id: Product.first.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should get edit' do
    get :edit, id: ProductTest.first.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end
end
