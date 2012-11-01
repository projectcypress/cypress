require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    collection_fixtures('vendors', '_id',"user_ids")
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures')
    collection_fixtures('products','_id','vendor_id')
    collection_fixtures('users',"_id", "vendor_ids")
    collection_fixtures('records', '_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
    sign_in @user
  end
  
  
  

  
  
  test "create" do
    v = Vendor.first
    count = v.products.count
    post(:create, {:product => {:name => 'A product',:vendor_id=>v.id}})
    assert_response :redirect
    assert_redirected_to vendor_path(v)
    v.reload
    assert_equal v.products.count, count+1
    

    post(:create, {:product => {:vendor_id=>v.id}})
    assert_response :success    
    
    v.reload
    assert_equal v.products.count, count+1
    
  end
  
  test "Delete vendors and take their associated records with them" do
    pro = Product.first
    count  = Product.count
    post(:destroy, {:id => pro.id})  
    
    assert_equal(Product.count, count -1)
    assert_response :redirect
    assert_redirected_to vendor_path(pro.vendor)
  end
  
  
  test "Update" do
    product = Product.first
    assert product.name != "updated"
    put :update,{:id =>product.id,:product =>{name: "updated"}}
    assert assigns(:product).name == "updated" 
    assert_response :redirect
    assert_redirected_to product_path(product)
  end
  
  
  test "Edit" do
    product = Product.first
    get :edit,{:id =>product.id}
    assert assigns(:product) ==product
    assert :success
  end
  
  test "show" do 
     product = Product.first
     get :show,{:id =>product.id}
     assert assigns(:product) ==product
     assert :success
  end
  
  
  test "new" do 
     v = Vendor.first
     get :new,{:vendor =>v.id}
     assert assigns(:product).vendor == v
     assert :success
  end
  
  
end
