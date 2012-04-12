require 'test_helper'

class MeasuresControllerTest < ActionController::TestCase
include Devise::TestHelpers

  setup do
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures')
    collection_fixtures('products','_id','vendor_id')
    collection_fixtures('records', '_id','test_id')
    collection_fixtures('product_tests', '_id')
    collection_fixtures('patient_populations', '_id')
    collection_fixtures('test_executions', '_id')
    collection_fixtures2('patient_cache','value', '_id' ,'test_id', 'patient_id')
    
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.first(:conditions => {:username => 'bobbytables'})
    sign_in @user
  end
  
  
  test "show" do
    m1 = Measure.where(:id => '0001').first
    pt = ProductTest.find("4f58f8de1d41c851eb000478")
    get :show, {:product_test_id=> pt.id,:id => m1.id,:format=>"html"}
    test = assigns[:test]
    product = assigns[:product]
    vendor  = assigns[:vendor]
    measures = assigns[:measures]
   

    assert test.id.to_s   == "4f58f8de1d41c851eb000478"
    assert product.id.to_s== "4f57a88a1d41c851eb000004"
    assert vendor.id.to_s == "4f57a8791d41c851eb000002"
    assert measures.count  == pt.count_measures

  end

   #test "patients" do
   # m1 = Measure.where(:id => '0001').first
   
   # get :patients, {:product_test_id =>'4f58f8de1d41c851eb000478' , :measure_id => m1.id}
   # test = assigns[:test]
   # product = assigns[:product]
   # vendor  = assigns[:vendor]  
   # result = assigns[:result]  

   # assert test.id.to_s   == "4f58f8de1d41c851eb000478"
   # assert product.id.to_s== "4f57a88a1d41c851eb000004"
   # assert vendor.id.to_s == "4f57a8791d41c851eb000002"
   # assert result['numerator']   == 44
   # assert result['antinumerator'] == 6
   # assert result['denominator'] == 50
   # assert result['exclusions']  == 0
   # assert assigns[:patients].count == 3


 # end

   test "minimal_set" do
    m1 = Measure.where(:id => '0001').first
   
    get :minimal_set, {:measure_ids => [m1.id], :format=>"json"}
   
    coverage = assigns[:coverage]  

    
    assert coverage.count == 0


  end

  

end
