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

  def test_available_attributes
    c1 = {}
    c1['dataElementAttributes'] = [{ 'attribute_name' => 'Test' }, { 'attribute_name' => 'id' }]
    assert_equal ['Test'], available_attributes(c1)
    c1['dataElementAttributes'][0]['attribute_valueset'] = 'vs'
    assert_equal ['Test:vs'], available_attributes(c1)
  end
end
