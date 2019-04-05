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

    c1['dataElementAttributes'] = [{ 'attribute_name' => 'Test' }]
    assert_equal 'Test', checklist_test_criteria_attribute(c1, 0)
  end
end
