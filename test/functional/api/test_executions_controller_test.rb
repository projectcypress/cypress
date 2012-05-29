require 'test_helper'

module Api
  class TestExecutionsControllerTest < ActionController::TestCase
    include Devise::TestHelpers
  
    setup do
      @controller = Api::TestExecutionsController.new
      collection_fixtures('vendors', '_id','product_ids',"user_ids")
      collection_fixtures('users',"_id","vendor_ids")
      collection_fixtures('products','_id','vendor_id','product_test_ids')
      collection_fixtures('product_tests','_id','product_id')
      collection_fixtures('test_executions','_id','product_test_id')
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = User.first(:conditions => {:first_name => 'bobby', :last_name => 'tables'})
      
      sign_in @user
    end
  
  
    test "index" do
      ven = Vendor.first
      prod = ven.products.first
      pt = prod.product_tests.first
      get :index, {vendor_id:Vendor.first.id, product_id:prod.id, product_test_id:pt.id}
      assert :success
    end
    
    test "show" do
      vendor = Vendor.first
      product = vendor.products.first
      pt = product.product_tests.first
      te =  pt.test_executions.first 
      
      get :show, {vendor_id: vendor.id, product_id: product.id, product_test_id: pt.id, id:te.id}
      assert :success
    end
    
    test "delete" do
      vendor = Vendor.first
      product = vendor.products.first
      pt = product.product_tests.first
      te = pt.test_executions.first 
     
      delete :destroy, {vendor_id: vendor.id, product_id: product.id, product_test_id: pt.id, id:te.id}
      assert 201
    end
    
  
    test "create" do      
      vendor = Vendor.first
      product = vendor.products.first
      pt = product.product_tests.first
      base_line = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_baseline.xml'), 'application/xml')
      reported_results = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_passing.xml'), 'application/xml')
    
      count = TestExecution.count
      post :create, {vendor_id: vendor.id, product_id:product.id, product_test_id:pt.id, baseline_results:base_line, reported_results:reported_results}
      assert :success
      assert_equal count+1,TestExecution.count
    
    end

  
  end
end
