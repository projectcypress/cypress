class InPatientProductTestControllerTest < ActionController::TestCase
  tests ProductTestsController
  
  
  
  setup do
     collection_fixtures('vendors', '_id',"user_ids")
     collection_fixtures('query_cache', 'test_id')
     collection_fixtures('measures')
     collection_fixtures('products','_id','vendor_id')
     collection_fixtures('users',"_id", "vendor_ids")
     collection_fixtures('records', '_id')

     @request.env["devise.mapping"] = Devise.mappings[:user]
     @user = User.first(:conditions => {:first_name => 'bobby', :last_name => 'tables'})
     sign_in @user
   end

   test "create " do
      pt = {:name =>'new4', :effective_date =>'12/21/2011', _type: "InpatientProductTest",:measure_ids => ["0013","0028","0421","" ]}
      get :create, {:product_test => pt , :type=>"InpatientProductTest" }
      assert_response :redirect, "Should redirect to show page"
      assert_equal 1, InpatientProductTest.where({:name => 'new4'}).count, "should have created a calculated product test"
   end
  
  
end