require 'test_helper'

class ChecklistTestsHelperTest < ActiveSupport::TestCase
  include ChecklistTestsHelper

  def test_length_of_stay_string
    field_value_low = {}
    field_value_low['low'] = {}
    field_value_low['low']['unit'] = 'd'
    field_value_low['low']['inclusive?'] = false
    field_value_low['low']['value'] = '90'
    assert_equal '90 d < stay', length_of_stay_string(field_value_low)

    field_value_high = {}
    field_value_high['high'] = {}
    field_value_high['high']['unit'] = 'd'
    field_value_high['high']['inclusive?'] = true
    field_value_high['high']['value'] = '120'
    assert_equal 'stay &#8804; 120 d', length_of_stay_string(field_value_high)

    field_value_mixed = {}
    field_value_mixed['high'] = field_value_high['high']
    field_value_mixed['low'] = field_value_low['low']
    assert_equal '90 d < stay &#8804; 120 d', length_of_stay_string(field_value_mixed)
  end
end
