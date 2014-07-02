require 'test_helper'

class MeasuresControllerTest < ActionController::TestCase
include Devise::TestHelpers

  setup do
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures',"_id",'bundle_id')
    collection_fixtures('products','_id','vendor_id')
    collection_fixtures('records', '_id','test_id','bundle_id')
    collection_fixtures('product_tests', '_id','bundle_id')
    collection_fixtures('patient_populations', '_id')
    collection_fixtures('test_executions', '_id')
    collection_fixtures2('patient_cache','value', '_id' ,'test_id','bundle_id')

    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
    sign_in @user
  end


  test "show" do

      m1 = Measure.find( '4fdb62e01d41c820f6000003')
      pt = ProductTest.find("4f58f8de1d41c851eb000478")
      get :show, {:product_test_id=> pt.id,:id => m1.id,:format=>"html"}
      assert_response :success
      test = assigns[:test]
      product = assigns[:product]
      vendor  = assigns[:vendor]
      measures = assigns[:measures]


      assert test.id.to_s   == "4f58f8de1d41c851eb000478"
      assert product.id.to_s== "4f57a88a1d41c851eb000004"
      assert vendor.id.to_s == "4f57a8791d41c851eb000002"
      assert measures.count  == pt.measure_ids.length

  end


   test "minimal_set" do

    measures =['99119911','99119922','99119933','99119944']
    get :minimal_set, {:bundle_id=>Bundle.first.id,:measure_ids => measures, :format=>"json"}
    coverage = assigns[:coverage]
    assert_equal  measures.length, coverage.count, "Expected coverage for all of the measures"

  end


  test "should be able to retreive measures for a given test type" do
      Measure.where({:type=>"ep"}).count
      get :by_type , {:bundle_id=>Bundle.first.id, :type=>"CalculatedProductTest",:format=>:js}
      assert_response :success
  end

  test "definition" do
    Measure.where({}).each do |measure|
      get :definition, {measure_id: measure}
      assert_response :success
    end
  end

  test "patients" do
   pt= ProductTest.where({}).first
   measure = pt.measures.first
   execution = pt.test_executions.first
   records  =  Result.where("value.test_id" => pt.id).where("value.measure_id" => measure.hqmf_id, "value.sub_id" => measure.sub_id)

   get :patients, {id: measure.id, product_test_id: pt, execution_id: execution}

   assert_response :success
   assert assigns[ :patients], "Should assign patients"
   assert assigns[ :product], "Should assign product"
   assert assigns[ :vendor], "Should assign vendor"
   assert assigns[ :execution], "Should assign execution"
   assert assigns[ :test], "Should assign test"


  end

end
