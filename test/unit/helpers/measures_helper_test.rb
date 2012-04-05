require 'test_helper'

class MeasuresHelperTest < ActionView::TestCase

	test "Should return correct measure css class" do
		result1 ={'numerator' => 10, 'denominator' => 5, 'exclusions' => 0, 'antinumerator' => 1}
		result2 ={'numerator' => 11, 'denominator' => 5, 'exclusions' => 0, 'antinumerator' => 1}
		result3 ={'numerator' => '?', 'denominator' => '?', 'exclusions' => '?', 'antinumerator' => '?'}
		
		assert measure_result_class(result1,result1,'numerator') == ''
		assert measure_result_class(result1,result2,'numerator') == 'fail'
		assert measure_result_class(result3,result3,'numerator') == 'na'
	end
end
