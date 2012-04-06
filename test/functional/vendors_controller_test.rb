require 'test_helper'

class VendorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    collection_fixtures('vendors', '_id',"user_ids")
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures')
    collection_fixtures('users',"_id", "vendor_ids")
    collection_fixtures('records', '_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.first(:conditions => {:username => 'bobbytables'})
    sign_in @user
  end
  
  test "index" do
    get :index
    assert_response :success
    assert assigns(:vendors).size == @user.vendors.count

  end
  
  test "create" do
    vcount = @user.vendors.count
    post(:create, {:vendor => {:name => 'An EHR', :measure_ids => ['0004', '0055'], :patient_population_id => 'all'}})
    assert_response :redirect
    @user.reload
    assert_equal @user.vendors.count , vcount+1
  end
  
  test "Delete vendors and take their associated records with them" do
    vcount = @user.vendors.count
    vendor_id = @user.vendors.first.id
    post(:destroy, {:vendor_id => vendor_id})  
    
    assert_equal(@user.vendors.count, vcount -1)
    assert_response :redirect
  end
  
  
  test "Update" do
   vendor = @user.vendors.first
   assert vendor.name != "twinkles"
   put :update, {:id=>vendor.id,:vendor=>{:name=> "twinkles"}}
   vendor.reload
   assert vendor.name=="twinkles"
  end
  
  
  test "show" do 
     get :show, {:vendor_id => @user.vendors.first.id}
     assert assigns(:vendor) == @user.vendors.first
  end
  
  
end
