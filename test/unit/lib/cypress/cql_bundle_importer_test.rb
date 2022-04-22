# frozen_string_literal: true

require 'test_helper'

class CqlBundleImporterTest < ActiveSupport::TestCase
  test 'should not import old bundle' do
    bundle_zip = File.new(File.join('test', 'fixtures', 'bundles', 'minimal_bundle_qdm_5_4.zip'))
    err = assert_raises(RuntimeError) do
      Cypress::CqlBundleImporter.import(bundle_zip, Tracker.new)
    end
    assert_equal('Please use bundles for year(s) 2020, 2021, 2022.', err.message)
  end

  test 'should successfully import bundle and perform calculations' do
    before_measure_count = Measure.count
    before_value_set_count = ValueSet.count
    before_patient_count = Patient.count
    before_results_count = IndividualResult.count
    bundle_zip = File.new(File.join('test', 'fixtures', 'bundles', 'minimal_bundle_qdm_5_5.zip'))
    Cypress::CqlBundleImporter.import(bundle_zip, Tracker.new)
    assert_equal (before_measure_count + 2), Measure.count
    # 21 valuesets from csv file, 3 direct reference codes
    assert_equal (before_value_set_count + 25), ValueSet.count
    assert_equal (before_patient_count + 1), Patient.count
    # only 2 individual results are saved
    assert_equal (before_results_count + 2), IndividualResult.count
    # Assert calculation is correct for a given patient
    measure_id = Measure.where(cms_id: 'CMS111v9').first.id
    result = IndividualResult.where(population_set_key: 'PopulationSet_1', measure_id: measure_id).first
    assert_equal 1, result.IPP
    assert_equal 1, result.MSRPOPL
    assert_equal [5], result.episode_results[result.episode_results.keys[0]]['observation_values']
    # a bundle that has not been precalculated will not have clause results
    assert result.clause_results.empty?
    bundle_patient = Patient.first
    assert_equal 0, bundle_patient.qdmPatient.substances.size
    assert_equal 1, bundle_patient.qdmPatient.medications.size
  end

  test 'should successfully import bundle and perform calculations with highlighting' do
    before_measure_count = Measure.count
    before_value_set_count = ValueSet.count
    before_patient_count = Patient.count
    before_results_count = IndividualResult.count
    bundle_zip = File.new(File.join('test', 'fixtures', 'bundles', 'minimal_bundle_qdm_5_5.zip'))
    Cypress::CqlBundleImporter.import(bundle_zip, Tracker.new, include_highlighting: true)
    assert_equal (before_measure_count + 2), Measure.count
    # 21 valuesets from csv file, 3 direct reference codes
    assert_equal (before_value_set_count + 25), ValueSet.count
    assert_equal (before_patient_count + 1), Patient.count
    # only 2 individual results are saved
    assert_equal (before_results_count + 2), IndividualResult.count
    # Assert calculation is correct for a given patient
    measure_id = Measure.where(cms_id: 'CMS111v9').first.id
    result = IndividualResult.where(population_set_key: 'PopulationSet_1', measure_id: measure_id).first
    assert_equal 1, result.IPP
    assert_equal 1, result.MSRPOPL
    assert_equal [5], result.episode_results[result.episode_results.keys[0]]['observation_values']
    # a bundle that has not been precalculated but uses include_highlighting = true will have clause results
    assert_not result.clause_results.empty?
  end

  test 'should successfully import precalculated bundle' do
    before_measure_count = Measure.count
    before_value_set_count = ValueSet.count
    before_patient_count = Patient.count
    before_results_count = IndividualResult.count
    bundle_zip = File.new(File.join('test', 'fixtures', 'bundles', 'minimal_bundle_qdm_5_5_with_calcs.zip'))
    Cypress::CqlBundleImporter.import(bundle_zip, Tracker.new)
    assert_equal (before_measure_count + 2), Measure.count
    # 21 valuesets from csv file, 3 direct reference codes
    assert_equal (before_value_set_count + 24), ValueSet.count
    assert_equal (before_patient_count + 1), Patient.count
    # only 2 individual results are saved
    assert_equal (before_results_count + 2), IndividualResult.count
    # Assert calculation is correct for a given patient
    measure_id = Measure.where(cms_id: 'CMS111v9').first.id
    result = IndividualResult.where(population_set_key: 'PopulationSet_1', measure_id: measure_id).first
    assert_equal 1, result.IPP
    assert_equal 1, result.MSRPOPL
    assert_equal [5], result.episode_results[result.episode_results.keys[0]]['observation_values']
    assert_not result.clause_results.empty?
  end
end
