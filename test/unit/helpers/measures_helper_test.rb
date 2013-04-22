require 'test_helper'

class MeasuresHelperTest < ActionView::TestCase

  setup do
    collection_fixtures('measures','bundle')
  end

	test "Should return correct measure css class" do
		result1 ={'numerator' => 10, 'denominator' => 5, 'exclusions' => 0, 'antinumerator' => 1}
		result2 ={'numerator' => 11, 'denominator' => 5, 'exclusions' => 0, 'antinumerator' => 1}
		result3 ={'numerator' => '?', 'denominator' => '?', 'exclusions' => '?', 'antinumerator' => '?'}
		
		assert measure_result_class(result1,result1,'numerator') == ''
		assert measure_result_class(result1,result2,'numerator') == 'fail'
		assert measure_result_class(result3,result3,'numerator') == 'na'
	end

  test "Should return correct measure categories" do
    sub_level = Measure.new(:name=>'test measure', :sub_id =>'c')
    sub_level.save!
    top_level = measure_categories(:top_level)
    all_measures = measure_categories(:all_by_measure)

    assert_equal 6, top_level.length , "Should be 6 topl level measures"
    assert_equal 7, all_measures.length , "SHould be 7 total measures"
  end

end
