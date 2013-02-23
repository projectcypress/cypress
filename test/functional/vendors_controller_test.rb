require 'test_helper'

class VendorsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    collection_fixtures('vendors', '_id',"user_ids")
    collection_fixtures('query_cache', 'test_id','bundle_id')
    collection_fixtures('measures',"_id",'bundle_id')
    collection_fixtures('users',"_id", "vendor_ids")
    collection_fixtures('records', '_id','bundle_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
    sign_in @user
  end
  
  test "index" do
    get :index
    assert_response :success
    assert assigns(:vendors).size == Vendor.count

    sign_out @user
    get :index
    assert_response :redirect
  end
  
  test "create" do
    vcount = Vendor.count
    post(:create, {:vendor => {:name => 'An EHR', :measure_ids => ['0004', '0055'], :patient_population_id => 'all'}})
    assert_response :redirect
    @user.reload
    assert_equal Vendor.count , vcount+1
    assert_redirected_to root_path
    
    post(:create, {:vendor => {}})
    @user.reload
    assert_equal Vendor.count , vcount+1
    assert_response :success
    
  end
  
  test "Delete Vendor and take their associated records with them" do
    vcount =Vendor.count
    vendor_id =Vendor.where({}).first.id
    post(:destroy, {:id => vendor_id})  
    
    assert_equal(Vendor.count, vcount -1)
    assert_response :redirect
    assert_redirected_to root_path
  end
  
  
  test "Update" do
   vendor =Vendor.first
   assert vendor.name != "twinkles"
   put :update, {:id=>vendor.id,:vendor=>{:name=> "twinkles"}}
   vendor.reload
   assert vendor.name=="twinkles"
  end
  
  
  test "show" do 
     vendor = Vendor.where({}).first
     get :show, {:id => vendor.id}
     assert assigns(:vendor) == vendor
  end
  
  
end
