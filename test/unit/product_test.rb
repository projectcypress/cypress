require 'test_helper'

#typo required because theres already a product test class
class ProducTest < ActiveSupport::TestCase

  setup do
 
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id','bundle_id')
    collection_fixtures('measures',"_id",'bundle_id')
    collection_fixtures('query_cache','_id','test_id','bundle_id')
    collection_fixtures('patient_cache','_id','bundle_id')
    
    @product1 = Product.find("4f57a88a1d41c851eb000004")
    @product2 = Product.find("4f636ae01d41c851eb00048e")
    @qrda_product = Product.find("515eeac93054cf180e0000f0")
  end

  test "Should know if its passing" do

    assert !@product1.passing? , "Failing product reporting as passing"
    assert  @product2.passing? , "Passing product reporting as failing"
  end

  test "Should return failing tests" do
    failing1 = @product1.failing_tests
    failing2 = @product2.failing_tests

    assert_equal 0, failing2.count, "Product2 reports wrong # of failing tests"
    assert_equal 1 , failing1.count  , "Product1 reports wrong # of failing tests"
    assert_equal "4f5a606b1d41c851eb000484", failing1[0]._id.to_s   ,"Product1 reports wrong test as failing"
  end

  test "Should return passing tests" do
   passing1 = @product1.passing_tests
   passing2 = @product2.passing_tests

   assert_equal 1,passing2.count  , "Product2 reports wrong # of passing tests"
   assert_equal 1, passing1.count  , "Product1 reports wrong # of passing tests"
   assert_equal "4f58f8de1d41c851eb000478", passing1[0]._id.to_s ,"Product1 reports wrong test as passing"
   assert_equal  "4f636b3f1d41c851eb000491" , passing2[0]._id.to_s , "Product2 reports wrong test as passing"
  end

  test "Should count passing tests" do
    assert_equal 1, @product1.count_passing 
    assert_equal 1, @product2.count_passing 
  end
  
  test "Should report success rate" do
    assert_equal 1.0/3.0, @product1.success_rate 
    assert_equal 1, @product2.success_rate 
  end

  test "Should group by cat 3" do
    @qrda_product.tests_by_cat3.each_pair do |cat3, cat1s|
      cat1s.each do |cat1|
        assert_equal cat1.calculated_test_id.to_s, cat3.id.to_s, "Calculated test ID for cat1 test #{cat1.id} (#{cat1.calculated_test_id}) did not match cat3 test #{cat3.id}"
      end
    end
  end
  
end
