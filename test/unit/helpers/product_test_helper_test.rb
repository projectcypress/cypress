require 'test_helper'

class ProductTestHelperTest < ActionView::TestCase

  setup do
    collection_fixtures('vendors', '_id')
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id')
  end

	test "Should report result class" do
    assert result_class('-',0) == 'na'
    assert result_class(nil,0) == 'na'
    assert result_class(1,0) == 'fail'
    assert result_class(1,1) == 'pass'
  end  


  test "Group measures by type" do
  	groups = group_measures_by_type(Measure.all)
    assert_equal 5, groups[:continuous].length,  "Should contain 5 CV measure"
    assert_equal 17, groups[:proportional].length, "Should contain 17 non CV measures"
  end  

end
