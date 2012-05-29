require 'test_helper'

module Api
class VendorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @controller = Api::VendorsController.new
    collection_fixtures('vendors', '_id', 'user_ids')
    collection_fixtures('users',"_id","vendor_ids")
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.first(:conditions => {:first_name => 'bobby', :last_name => 'tables'})
   
    sign_in @user
  end
  
  test "index" do
    count = Vendor.count
    get :index
    assert_response :success
    assert assigns(:vendors).size == count
  end
  
  
  test "show" do
    get :show, {id: Vendor.first.id}
    assert_response :success
  end
  
  test "create" do
    count = Vendor.count
    @request.env['RAW_POST_DATA'] =  {:name => 'An EHR', :measure_ids => ['0004', '0055'], :patient_population_id => 'all'}.to_json
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :create
    assert_response :redirect
    @user.reload
    assert Vendor.count == count+1
  end
  
  
  test "Update" do
    v =Vendor.first
    v.name = "Renamed"
    @request.env['RAW_POST_DATA'] =  v.to_json
    @request.env['CONTENT_TYPE'] = 'application/json'
    put :update,{:id=>v.id}
    assert_response :redirect

    assert Vendor.find(v.id).name == "Renamed"
    
  end
  
  
  
  test "Delete vendors and take their associated records with them" do
    count = Vendor.count
    post(:destroy, {id: Vendor.first.id})
    assert_equal(count-1, Vendor.count)
    assert_response 201
  end
end
end