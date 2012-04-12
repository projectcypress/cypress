require 'test_helper'

module Api
class VendorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @controller = Api::VendorsController.new
    collection_fixtures('vendors', '_id', 'user_ids')
    collection_fixtures('users',"_id","vendor_ids")
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.first(:conditions => {:username => 'bobbytables'})
    @user.vendors << Vendor.first
    sign_in @user
  end
  
  test "index" do
    count = @user.vendors.count
    get :index
    assert_response :success
    assert assigns(:vendors).size == count
  end
  
  
  test "show" do
    get :show, {id: @user.vendors.first.id}
    assert_response :success
  end
  
  test "create" do
    count = @user.vendors.count
    @request.env['RAW_POST_DATA'] =  {:name => 'An EHR', :measure_ids => ['0004', '0055'], :patient_population_id => 'all'}.to_json
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :create
    assert_response :redirect
    @user.reload
    assert @user.vendors.count == count+1
  end
  
  
  test "Update" do
    v = @user.vendors.first
    v.name = "Renamed"
    @request.env['RAW_POST_DATA'] =  v.to_json
    @request.env['CONTENT_TYPE'] = 'application/json'
    put :update,{:id=>v.id}
    assert_response :redirect
    @user.reload
    assert Vendor.find(v.id).name == "Renamed"
    
  end
  
  
  
  test "Delete vendors and take their associated records with them" do
    count = @user.vendors.count
    post(:destroy, {id: @user.vendors.first.id})
    @user.reload
    assert_equal(count-1, @user.vendors.count)
    assert_response 201
  end
end
end