# frozen_string_literal: true

require 'test_helper'

class ChecklistTestsHelperTest < ActiveSupport::TestCase
  include ChecklistTestsHelper

  # This ensures that the filtering on lookup_codevalues properly limits results
  # to a specific bundle when specified
  def test_lookup_codevalues_multiple_bundles
    @bundle1 = FactoryBot.create(:static_bundle)
    @bundle2 = FactoryBot.create(:bundle)

    assert_empty lookup_codevalues(@bundle1.value_sets.first.oid, @bundle2)
  end

  def test_checklist_test_criteria_attribute
    c1 = {}

    c1['dataElementAttributes'] = [{ 'attribute_name' => 'Test', 'attribute_valueset' => 'vs' }]
    assert_equal 'Test', checklist_test_criteria_attribute(c1, 0)
    assert_equal 'Test:vs', checklist_test_criteria_attribute(c1, 0, include_vs: true)
    assert_equal '', checklist_test_criteria_attribute({}, 0)
    assert_equal '', checklist_test_criteria_attribute(c1, 1)
  end

  def test_valueset_oid_or_code
    sb = FactoryBot.create(:static_bundle)
    drc = sb.value_sets.detect { |value_set| value_set.oid[0, 3] == 'drc' }
    drc_code = drc.concepts.first.code
    # If the valueset is a direct reference code, the the method returns the code value
    assert_equal valueset_oid_or_code(drc.oid), drc_code

    # If the valueset is a valueset, the the method returns the oid
    vs = sb.value_sets.detect { |value_set| value_set.oid[0, 3] != 'drc' }
    assert_equal valueset_oid_or_code(vs.oid), vs.oid
  end

  def test_available_attributes
    c1 = {}
    c1['dataElementAttributes'] = [{ 'attribute_name' => 'Test' }, { 'attribute_name' => 'id' }]
    assert_equal ['Test'], available_attributes(c1, '8A6D040F-8B1E-D837-018B-8C58F1D61E34')
    c1['dataElementAttributes'][0]['attribute_valueset'] = 'vs'
    assert_equal ['Test:vs'], available_attributes(c1, '8A6D040F-8B1E-D837-018B-8C58F1D61E34')
  end

  def test_removal_of_problematic_attributes
    c1 = { '_type' => 'QDM::AllergyIntolerance' }
    c1['dataElementAttributes'] = [{ 'attribute_name' => 'type', 'attribute_valueset' => '2.16.840.1.113762.1.4.1170.6' }, { 'attribute_name' => 'Test' }]
    # Attribute will be removed with matching type, attrbute, valueset and measure
    assert_equal ['Test'], available_attributes(c1, '8A6D040F-8B1E-D837-018B-8C58F1D61E33')
    # Attribute will not be removed without with matching measure
    assert_equal ['Test', 'type:2.16.840.1.113762.1.4.1170.6'], available_attributes(c1, '8A6D040F-8B1E-D837-018B-8C58F1D61E34')
    c1['_type'] = 'QDM::AdverseEvent'
    # Attribute will not be removed without with matching type
    assert_equal ['Test', 'type:2.16.840.1.113762.1.4.1170.6'], available_attributes(c1, '8A6D040F-8B1E-D837-018B-8C58F1D61E33')
  end
end
