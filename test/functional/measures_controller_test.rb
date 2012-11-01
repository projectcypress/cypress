require 'test_helper'

class MeasuresControllerTest < ActionController::TestCase
include Devise::TestHelpers

  setup do
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures',"_id")
    collection_fixtures('products','_id','vendor_id')
    collection_fixtures('records', '_id','test_id')
    collection_fixtures('product_tests', '_id')
    collection_fixtures('patient_populations', '_id')
    collection_fixtures('test_executions', '_id')
    collection_fixtures2('patient_cache','value', '_id' ,'test_id', 'patient_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
    sign_in @user
  end
  
  
  test "show" do
    pending "wrong place for this to be. needs to be reimplemented in product_execution not measure controller" do
      m1 = Measure.where(:id => '0001').first
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
      assert measures.count  == pt.count_measures
   end
  end


   test "minimal_set" do
    m1 = Measure.where(:hqmf_id => '0001').first
    m2 = Measure.where(:hqmf_id => '0002').first
    get :minimal_set, {:measure_ids => [m1.id,m2.id], :format=>"json"}
    coverage = assigns[:coverage]  
    assert coverage.count == 0

    m3 = Measure.where(:hqmf_id => '0348').first
    get :minimal_set, {:measure_ids => [m1.id,m2.id,m3.id], :format=>"json"}
    coverage = assigns[:coverage] 
    assert coverage.count == 0

  end
  
  
  test "shopuld be able to retreive measures for a given test type" do
      Measure.where({:type=>"ep"}).count
      get :by_type , {:type=>"CalculatedProductTest",:format=>:js}
      assert_response :success
  end

  

end
