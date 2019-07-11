require 'test_helper'

class PatientAnalysisHelperTest < ActiveSupport::TestCase
  include PatientAnalysisHelper

  def setup
    @bundle = FactoryBot.create(:static_bundle)
    @vendor = FactoryBot.create(:vendor_with_points_of_contact)
    FactoryBot.create(:vendor_test_patient, bundleId: @bundle._id, correlation_id: @vendor.id)
  end

  def test_generate_analysis_no_measures
    analysis = generate_analysis(@vendor.patients, nil, @bundle)
    assert_equal 1, analysis['patient_count']
    assert_equal 0.1, analysis['measure_coverage']
    assert_equal 0.02857142857142857, analysis['population_coverage']
    assert_equal 8, analysis['data_element_types'].size
    assert_equal 8, analysis['value_sets'].size
    assert_equal 23, analysis['uncovered_value_sets'].size
    assert_equal 0.20689655172413793, analysis['value_set_coverage']
    assert_equal 29, analysis['uncovered_vs_code_sys'].size
    assert_equal 0.20689655172413793, analysis['value_set_code_system_coverage']
    assert_equal 0.20689655172413793, analysis['average_percent_vs_codes']
  end

  def test_generate_analysis_single_measures
    analysis = generate_analysis(@vendor.patients, @bundle.measures.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first, @bundle)
    assert_equal 1, analysis['patient_count']
    assert_equal 1.0, analysis['measure_coverage']
    assert_equal 0.2857142857142857, analysis['population_coverage']
    assert_equal 8, analysis['data_element_types'].size
    assert_equal 8, analysis['value_sets'].size
    assert_equal 3, analysis['uncovered_value_sets'].size
    assert_equal 0.625, analysis['value_set_coverage']
    assert_equal 8, analysis['uncovered_vs_code_sys'].size
    assert_equal 0.625, analysis['value_set_code_system_coverage']
    assert_equal 0.625, analysis['average_percent_vs_codes']
  end
end
