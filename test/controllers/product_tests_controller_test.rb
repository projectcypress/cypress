require 'test_helper'
class ProductTestsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'users')
    sign_in User.first
  end

  test 'should get index' do
    # do this for all users
    get :index, product_id: Product.first.id
    assert_response :success
    assert_not_nil assigns(:product_tests)
    assert_not_nil assigns(:product)
  end

  test 'should get show' do
      # do this for all users
    my_product = ProductTest.first
    get :show, id: my_product.id, product_id: my_product.product.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should get show measure test' do
    mt = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    mt.save!
      # do this for all users
    get :show, id: mt.id, product_id: mt.product.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should get edit' do
      # do this for admin , atl and owner
    get :edit, id: ProductTest.first.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should be able to download zip file of patients in qrda format' do
      # do this for all users
    get :download, :id => ProductTest.first.id, :format => :qrda
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should be able to download zip file of patients in html format' do
      # do this for all users
    get :download, :id => ProductTest.first.id, :format => :html
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  # need negative tests for user that does not have owner or vendor access 

end
