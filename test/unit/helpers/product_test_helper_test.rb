require 'test_helper'

class ProductTestHelperTest < ActionView::TestCase

	test "Should report result class" do
    assert result_class('-',0) == 'na'
    assert result_class(1,0) == 'f'
    assert result_class(1,1) == ''
  end  

end
