require 'test_helper'

module Api
  class ProductsControllerTest < ActionController::TestCase
    include Devise::TestHelpers
  
    setup do
      @controller = Api::ProductsController.new
      collection_fixtures('vendors', '_id','product_ids',"user_ids")
      collection_fixtures('users',"_id","vendor_ids")
      collection_fixtures('products','_id','vendor_id')
    
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.first(:conditions => {:username => 'bobbytables'})
      
      sign_in @user
    end
  
  
    test "index" do
      get :index, {vendor_id: Vendor.first.id}
      assert :success
    end
    
    test "show" do
      vendor = Vendor.first
      product = vendor.products.first
      get :show, {vendor_id: vendor.id, id: product.id }
      assert :success
    end
    
    test "delete" do
      vendor = Vendor.first
      product = vendor.products.first
      delete :destroy, {vendor_id: vendor.id, id: product.id }
      assert 201
    end
    
    
    test "create" do
      vendor = Vendor.first
      product={name:"hey"}
      count = vendor.products.count
      @request.env['RAW_POST_DATA'] = product.to_json
      @request.env['CONTENT_TYPE'] = 'application/json'
      post :create, {vendor_id: vendor.id}
      vendor.reload
      assert_equal count+1,vendor.products.count
      assert :redirect
    end
  
  end
end
