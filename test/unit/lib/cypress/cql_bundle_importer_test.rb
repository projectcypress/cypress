require 'test_helper'

class CqlBundleImporterTest < ActiveSupport::TestCase
  test 'should successfully import bundle and perform calculations' do
    before_measure_count = Measure.count
    before_value_set_count = ValueSet.count
    before_patient_count = Patient.count
    before_results_count = IndividualResult.count
    bundle_zip = File.new(File.join('test', 'fixtures', 'bundles', 'minimal_bundle_qdm_5_4.zip'))
    Cypress::CqlBundleImporter.import(bundle_zip)
    assert_equal (before_measure_count + 2), Measure.count
    # 21 valuesets from csv file, 3 direct reference codes
    assert_equal (before_value_set_count + 24), ValueSet.count
    assert_equal (before_patient_count + 1), Patient.count
    # only 2 individual results are saved
    assert_equal (before_results_count + 2), IndividualResult.count
    # Assert calculation is correct for a given patient
    measure_id = Measure.where(cms_id: 'CMS111v8').first.id
    result = IndividualResult.where(population_set_key: 'PopulationSet_1', measure_id: measure_id).first
    assert_equal 1, result.IPP
    assert_equal 1, result.MSRPOPL
    assert_equal [5], result.episode_results[result.episode_results.keys[0]]['observation_values']
  end
end
