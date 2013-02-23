require 'test_helper'

class ProductTestsControllerTest < ActionController::TestCase
include Devise::TestHelpers

  setup do
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('users',"_id", "product_ids","product_test_ids")
    collection_fixtures('measures','bundle_id', "_id")
    collection_fixtures('bundles','_id')
    collection_fixtures('products','_id','vendor_id', "user_id")
    collection_fixtures('records', '_id','test_id','bundle_id')
    collection_fixtures('product_tests', '_id','product_id',"user_id",'bundle_id')
    collection_fixtures('patient_populations', '_id')
    collection_fixtures('test_executions', '_id','product_test_id')
    collection_fixtures2('patient_cache','value', '_id' ,'test_id', 'patient_id','bundle_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
    sign_in @user
  end
  



  test "show" do

      pt = ProductTest.find("4f58f8de1d41c851eb000478")
      ex  = TestExecution.where(:product_test_id => pt.id).first
      get :show, {:id => pt.id.to_s}

      assert_response :success
      assert_equal pt.id , assigns[:test].id , "Product Test id did not match expected id"
      
    
      get :show, {:id => pt.id, :test_execution_id => ex.id}

      assert_equal ex.id, assigns[:test_execution].id, "Execution id did not match expected id"
      assert_equal pt.id , assigns[:test].id , "Product Test id did not match expected id"

  end

  test "new" do
      p1 = Product.where({}).first
      get :new, {:product_id => p1.id }

      assert_response :success
      assert !assigns[:test].nil?
      assert assigns[:product].id == p1.id
      assert assigns[:vendor].id  == p1.vendor.id
  end

  
  
  test "create without product test type " do  
    pt1 = {:name =>'new1', :effective_date_end =>'12/21/2011' , :upload_format =>'c32', :patient_population =>'test'}
    put :create, {:product_test => pt1 }
    assert_response 500, "Create without type should raise an error"
  end
  

  test "edit" do
    pt = ProductTest.where({}).first
    get :edit, {product_id: pt.product.id, id: pt.id}
    assert_response :success
    
    assert assigns[:test].id == pt.id
    assert assigns[:product].id == pt.product.id
    assert assigns[:vendor].id  == pt.product.vendor.id

  end

  test "update" do
    pt = ProductTest.where({}).first
    updated_attributes = {:name => 'Updated test name', :description => 'Updated Description'}
    post :update, {:id => pt.id, :product_test => updated_attributes}

    assert_response :redirect
    pt_updated = ProductTest.find(pt.id)
    assert pt_updated.name == 'Updated test name'
    assert pt_updated.description == 'Updated Description'
  end

  test "destroy" do
    pt = ProductTest.where({}).first
    delete :destroy, {:id => pt.id}
    assert_response :redirect
    destroyed = ProductTest.where(:id => pt.id)
    assert_equal 0,  destroyed.count, "There shouldn't be a ProductTest in the db with the id of the one just destroyed"
  end



  test "download" do
    pt = ProductTest.find("4f58f8de1d41c851eb000478")

  

    get :download,{:id => pt.id , :format => 'html'}
    assert_response :success,"Failed to download HTML zip file"
  end
  
  test "add note" do
    assert ProductTest.find("4f58f8de1d41c851eb000478").notes.empty?

    post(:add_note, {:id => "4f58f8de1d41c851eb000478", :note => {:text => "This is notable"}})
    assert_response :redirect
    assert ProductTest.find("4f58f8de1d41c851eb000478").notes.count == 1
  end
  
  test "delete note" do
    test = ProductTest.find("4f6b78801d41c851eb0004a7")
    assert_equal test.notes.size, 1
    
    # BSONify the ID of the note connected to this ProductTest so that it's findable during deletion
    test.notes.first["_id"] = Moped::BSON::ObjectId(test.notes.first["_id"])
    test.save
    
    delete(:delete_note, {:id => "4f6b78801d41c851eb0004a7", "note" => {"id" => "4fa287f99e8f54e9e9000038"}})
    assert_response :redirect
    assert ProductTest.find('4f6b78801d41c851eb0004a7').notes.empty?
  end
  
  test "email records" do
    test = ProductTest.find("4f58f8de1d41c851eb000478")
    post :email, { :id => test, :format => 'html' ,:email=> test.product.vendor.email}
    
    assert_response :redirect
  end

  test "qrda_cat3" do

    test = ProductTest.find("4f58f8de1d41c851eb000478")
    get :qrda_cat3, {:id=> test,:format=>:xml}
    assert_response :success
  end



end