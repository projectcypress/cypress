class InPatientProductTestControllerTest < ActionController::TestCase
  tests ProductTestsController
  
  
  
  setup do
     collection_fixtures('vendors', '_id',"user_ids")
     collection_fixtures('query_cache', 'test_id')
     collection_fixtures('measures', "_id", "bundle_id")
     collection_fixtures('bundles', "_id")
     collection_fixtures('products','_id','vendor_id')
     collection_fixtures('users',"_id", "vendor_ids")
     collection_fixtures('records', '_id')

     @request.env["devise.mapping"] = Devise.mappings[:user]
     @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
     sign_in @user
   end

   test "create " do
      product = Product.where({}).first
      pt = {:product_id=>product.id,:name =>'new4', :effective_date =>Bundle.active.first.effective_date ,_type: "InpatientProductTest",:measure_ids => ["8A4D92B2-3887-5DF3-0139-0D01C6626E46",
 "8A4D92B2-3887-5DF3-0139-0D08A4BE7BE6",
 "8A4D92B2-3887-5DF3-0139-11B262260A92"]}
      get :create, {:bundle_id=>Bundle.first.id,:product_test => pt , :type=>"InpatientProductTest" }
      assert_response :redirect, "Should redirect to show page"

      assert_equal 1, InpatientProductTest.where({:name => 'new4'}).count, "should have created an inpatient product test"
   end
  
  
end