require 'test_helper'

class MeasureEvaluatorTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id')
    collection_fixtures('measures')
    collection_fixtures('query_cache','_id','test_id')
    collection_fixtures('patient_cache','_id')
    
  end

  test "Should evaluate a measure" do
    
  end
  
  test "Should evaluate for static records" do
  
  end
  
end
