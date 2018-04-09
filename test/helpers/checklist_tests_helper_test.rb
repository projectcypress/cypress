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

  def test_checklist_test_criteria_attribute
    measure = FactoryGirl.create(:static_measure)
    c1 = {}
    c2 = {}
    c3 = {}

    c1[:negation] = true
    assert_equal 'Negation Code', checklist_test_criteria_attribute(measure, c1)

    c2[:value] = { type: 'IVL_PQ',
                   high: { type: 'PQ',
                           unit: 'mg/dL',
                           value: '100' } }
    assert_equal 'Result', checklist_test_criteria_attribute(measure, c2)

    c3[:value] = { type: 'CD', system: 'Administrative Sex', code: 'F' }
    assert_equal '', checklist_test_criteria_attribute(measure, c3)
  end
end
