require 'test_helper'
class ProductTestsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('vendors', 'products', 'product_tests', 'users')
    sign_in User.first
  end

  test 'should get index' do
    get :index, product_id: Product.first.id
    assert_response :success
    assert_not_nil assigns(:product_tests)
    assert_not_nil assigns(:product)
  end

  test 'should get show' do
    my_product = ProductTest.first
    get :show, id: my_product.id, product_id: my_product.product.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should get show measure test' do
    mt = Product.first.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    mt.save!
    get :show, id: mt.id, product_id: mt.product.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should get edit' do
    get :edit, id: ProductTest.first.id
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should be able to download zip file of patients in qrda format' do
    get :download, :id => ProductTest.first.id, :format => :qrda
    assert_response :success
    assert_not_nil assigns(:product_test)
  end

  test 'should be able to download zip file of patients in html format' do
    get :download, :id => ProductTest.first.id, :format => :html
    assert_response :success
    assert_not_nil assigns(:product_test)
  end
end
