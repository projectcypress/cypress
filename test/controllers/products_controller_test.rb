require 'test_helper'
class ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    collection_fixtures('bundles', 'vendors', 'products', 'product_tests', 'tasks', 'users', 'measures')
    sign_in User.first
  end

  teardown do
    drop_database
  end

  test 'should get index' do
    get :index, vendor_id: Vendor.first.id
    assert_response :redirect
  end

  test 'should get new' do
    get :new, vendor_id: Vendor.first.id, product_id: Product.new
    assert_response :success
    assert_not_nil assigns(:product)
  end

  test 'should get edit' do
    get :edit, id: Product.first.id
    assert_response :success
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:selected_measure_ids)
  end

  test 'should destroy' do
    get :destroy, id: Product.first.id
    assert_response :redirect
  end

  test 'should get show' do
    get :show, id: Product.first.id, vendor_id: Product.first.vendor.id
    assert_response :success
    assert_not_nil assigns(:product)
  end

  test 'should be able to update measures' do
    pt = Product.new(vendor: Vendor.first, name: 'test_product', c1_test: true)

    ids = %w('0001', '0002', '0003', '0004')
    ids.each do |mid|
      pt.product_tests.build({ name: 'test_#{mid}',
                               measure_ids: [mid],
                               bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest).save!
    end
    pt.save!
    assert_equal ids, pt.measure_ids, 'product should have same measure ids'

    new_ids = ['8A4D92B2-397A-48D2-0139-B0DC53B034A7']
    put :update, id: pt.id, product: pt.attributes, product_test: { measure_ids: new_ids }
    pt.reload
    assert_equal new_ids, pt.measure_ids
  end
end
