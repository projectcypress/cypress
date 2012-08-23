require 'test_helper'
require 'zip/zip'

class ProductTestTest < ActiveSupport::TestCase
  setup do
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('product_tests', '_id')
    
    @test1 = ProductTest.find("4f58f8de1d41c851eb000478")
    @test2 = ProductTest.find("4f5a606b1d41c851eb000484")
  end

  test "Should know if its passing" do
    pending  "need to implement"
  end
  
  test "Should return its executions in order" do
    pending "need to implement"
  end
  
  test "Should return the measure defs" do
    defs = @test1.measures
    
    assert defs[0].key == "0001"
    assert defs[1].key == "0002"
  end
  
  
  test "should be able to retrieve patient records to evaluate against" do
    
  end
  
  
  test "Should know how many measures its testing" do
    assert @test1.measures.count == 2
  end


end