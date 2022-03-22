# frozen_string_literal: true

require 'test_helper'

class ChecklistSourceDataCriteriaTest < ActiveJob::TestCase
  def setup
    @vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    @product = @vendor.products.build(name: "my product #{rand}", measure_ids: measure_ids, bundle_id: @bundle._id)
    @product.c1_test = true
    @product.save!
    @test = @product.product_tests.create!({ name: "my checklist test #{rand}", measure_ids: measure_ids }, ChecklistTest)
    @test.create_checked_criteria
    @test.tasks.create!({}, C1ChecklistTask)
  end

  # assumes Encounter Performed with dischargeDisposition:1.5.6.7 selected is first checked criteria
  def test_change_criteria
    # attribute change
    @test.checked_criteria[0].replacement_attribute = 'relevantPeriod'
    @test.checked_criteria[0].change_criteria
    has_relevant_period = @test.checked_criteria.any? do |cc|
      cc.source_data_criteria['dataElementAttributes'][cc.attribute_index]['attribute_name'] == 'relevantPeriod'
    end
    assert has_relevant_period

    # attribute change with valueset
    @test.checked_criteria[0].replacement_attribute = 'dischargeDisposition:1.5.6.7'
    @test.checked_criteria[0].change_criteria
    has_discharge_disposition = @test.checked_criteria.any? do |cc|
      cc.source_data_criteria['dataElementAttributes'][cc.attribute_index]['attribute_name'] == 'dischargeDisposition'
    end
    assert has_discharge_disposition

    # data_criteria change
    index = Measure.first.source_data_criteria.index { |a| a['description'] == 'Patient Characteristic Ethnicity: Ethnicity' }
    @test.checked_criteria[0].replacement_data_criteria = Measure.first.source_data_criteria[index]._id.to_s
    @test.checked_criteria[0].change_criteria
    has_ethnicity = @test.checked_criteria.any? { |cc| cc.source_data_criteria['description'] == 'Patient Characteristic Ethnicity: Ethnicity' }
    assert has_ethnicity

    # both change
    index = Measure.first.source_data_criteria.index { |a| a['description'] == 'Encounter, Performed: EncounterInpatient' }
    @test.checked_criteria[0].replacement_data_criteria = Measure.first.source_data_criteria[index]._id.to_s
    @test.checked_criteria[0].replacement_attribute = 'relevantPeriod'
    @test.checked_criteria[0].change_criteria
    has_ethnicity = @test.checked_criteria.any? { |cc| cc.source_data_criteria['description'] == 'Patient Characteristic Ethnicity: Ethnicity' }
    assert has_ethnicity
  end

  def test_index_for_replacement_attribute
    criteria = @test.checked_criteria[0]
    assert_nil criteria.index_for_replacement_attribute(criteria.source_data_criteria)
    criteria.replacement_attribute = 'dischargeDisposition:1.5.6.7'
    assert_equal 1, criteria.index_for_replacement_attribute(criteria.source_data_criteria)
    criteria.replacement_attribute = 'relevantPeriod'
    assert_equal 0, criteria.index_for_replacement_attribute(criteria.source_data_criteria)
  end

  def test_automated_drc_recording
    checked_criteria = @test.checked_criteria[0]
    # Find the underlying Souce Data Criteria and swap the valueset with a direct refrence code
    sdc = @test.measures.first.source_data_criteria.find(checked_criteria.source_data_criteria['_id'])
    drc = ValueSet.find_by(display_name: 'Birthdate')
    sdc.codeListId = drc.oid
    sdc.save

    assert_nil checked_criteria.code, 'criteria code should start as nil'
    checked_criteria.save
    assert_equal checked_criteria.code, drc.concepts.first.code, 'after save, the checked criteria code should match the drc code'
  end

  def test_change_attribute?
    cc = @test.checked_criteria[0]
    cc.replacement_attribute = 'relevantPeriod'
    assert cc.change_attribute?(cc.source_data_criteria)
  end
end
