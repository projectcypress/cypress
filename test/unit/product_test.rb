require 'test_helper'

#typo required because theres already a product test class
class ProducTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id')
    collection_fixtures('measures')
    collection_fixtures('query_cache','_id','test_id')
    collection_fixtures('patient_cache','_id')
    
    @product1 = Product.find("4f57a88a1d41c851eb000004")
    @product2 = Product.find("4f636ae01d41c851eb00048e")
  end

  test "Should know if its passing" do
    prod3 = Product.new()
    assert !prod3.passing?, "Empty Product reporting as passing"
    assert !@product1.passing? , "Failing product reporting as passing"
    assert  @product2.passing? , "Passing product reporting as failing"
  end

  test "Should return failing tests" do
    failing1 = @product1.failing_tests
    failing2 = @product2.failing_tests

    assert failing2.count == 0 , "Product2 reports wrong # of failing tests"
    assert failing1.count == 1 , "Product1 reports wrong # of failing tests"
    assert failing1[0]._id.to_s == "4f5a606b1d41c851eb000484" ,"Product1 reports wrong test as failing"
  end

  test "Should return passing tests" do
   passing1 = @product1.passing_tests
   passing2 = @product2.passing_tests

   assert passing2.count == 1 , "Product2 reports wrong # of passing tests"
   assert passing1.count == 1 , "Product1 reports wrong # of passing tests"
   assert passing1[0]._id.to_s == "4f58f8de1d41c851eb000478" , "Product1 reports wrong test as passing"
   assert passing2[0]._id.to_s == "4f636b3f1d41c851eb000491" , "Product2 reports wrong test as passing"
  end

  test "Should count passing tests" do
    assert @product1.count_passing == 1
    assert @product2.count_passing == 1
  end
  
  test "Should report success rate" do
    assert Product.new().success_rate == 0
    assert @product1.success_rate == 0.5
    assert @product2.success_rate == 1
  end
end
