require 'test_helper'

class CqlBundleImporterTest < ActiveSupport::TestCase
  setup do
    @fake_bundle_dir = Dir.new File.join('test', 'fixtures', 'bundles', 'measures_only_bundle')
  end

  test 'should successfully import bundle and perform calculations' do
    before_measure_count = Measure.count()
    before_value_set_count = ValueSet.count()
    before_patient_count = Patient.count()
    before_results_count = IndividualResult.count()
    bundle_zip = File.new(File.join('test', 'fixtures', 'bundles', 'measures_only_bundle.zip'))
    bundle = Cypress::CqlBundleImporter.import(bundle_zip)
    measure = Measure.where({bundle_id: bundle.id}).last()
    patient = Patient.where({bundleId: bundle.id}).last()
    assert_equal (before_measure_count + 2), Measure.count()
    assert_equal (before_value_set_count + 21), ValueSet.count()
    assert_equal (before_patient_count + 1), Patient.count()
    assert_equal (before_results_count + 9), IndividualResult.count()
    # Assert calculation is correct for a given patient
    measure_id = Measure.where(cms_id: "CMS111v8").first().id
    result = IndividualResult.where(population_set_key: "PopulationSet_1", measure_id: measure_id).first
    assert_equal 1, result.IPP
    assert_equal 1, result.MSRPOPL
    assert_equal [5], result.episode_results[result.episode_results.keys[0]]['values']
  end
end