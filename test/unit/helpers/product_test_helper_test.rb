require 'test_helper'

class ProductTestHelperTest < ActionView::TestCase

	test "Should report result class" do
    assert result_class('-',0) == 'na'
    assert result_class(nil,0) == 'na'
    assert result_class(1,0) == 'fail'
    assert result_class(1,1) == 'pass'
  end  


  test "Group measures by type" do
  	groups = group_measures_by_type(Measure.all)
    assert_equal 3, groups[:continuous].length,  "Should contain 3 CV measure"
    assert_equal 6, groups[:proportional].length, "Should contain 6 non CV measures"
  end  

end
