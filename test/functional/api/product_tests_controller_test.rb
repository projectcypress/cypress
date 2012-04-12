require 'test_helper'

module Api
  class ProductTestsControllerTest < ActionController::TestCase
    include Devise::TestHelpers
  
    setup do
      @controller = Api::ProductTestsController.new
      collection_fixtures('vendors', '_id','product_ids',"user_ids")
      collection_fixtures('users',"_id","vendor_ids")
      collection_fixtures('products','_id','vendor_id','product_test_ids')
      collection_fixtures('product_tests','_id','product_id')
    
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.first(:conditions => {:username => 'bobbytables'})
      
      sign_in @user
    end
  
  
    test "index" do
      ven = @user.vendors.first
      prod = ven.products.first
      get :index, {vendor_id: @user.vendors.first.id, product_id:prod.id}
      assert :success
    end
    
    test "show" do
      vendor = @user.vendors.first
      product = vendor.products.first
      pt = product.product_tests.first
      get :show, {vendor_id: vendor.id, product_id: product.id, id: pt.id}
      assert :success
    end
    
    test "delete" do
      vendor = @user.vendors.first
      product = vendor.products.first
      pt = product.product_tests.first
      delete :destroy, {vendor_id: vendor.id, product_id: product.id, id: pt.id}
      assert 201
    end
    
    
    test "create" do
      vendor = @user.vendors.first
      product = vendor.products.first
      count = product.product_tests.count
      pt={name:"hey", effective_date:1324443600}
      @request.env['RAW_POST_DATA'] = pt.to_json
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :create, {vendor_id: vendor.id, product_id:product.id}
      assert :redirect
      assert_equal count+1,product.product_tests.count
    end
  
  end
end
