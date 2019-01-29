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
    c2 = {}
    c3 = {}

    c1[:attributes] = [{ attribute_name: 'Test' }]
    assert_equal 'Test', checklist_test_criteria_attribute(c1, 0)

    c2[:value] = { type: 'IVL_PQ',
                   high: { type: 'PQ',
                           unit: 'mg/dL',
                           value: '100' } }
    assert_equal 'Result', checklist_test_criteria_attribute(c2, nil)

    c3[:value] = { type: 'CD', system: 'Administrative Sex', code: 'F' }
    assert_equal '', checklist_test_criteria_attribute(c3, nil)
  end
end
