require 'test_helper'

class CqlBundleImporterTest < ActiveSupport::TestCase
  setup do
    @fake_bundle_dir = Dir.new File.join('test', 'fixtures', 'bundles', 'measures_only_bundle')
  end

  test 'should successfully calculate from bundle' do
    before_measure_count = Measure.count()
    before_value_set_count = ValueSet.count()
    before_patient_count = Patient.count()
    bundle_zip = File.new(File.join('test', 'fixtures', 'bundles', 'measures_only_bundle.zip'))
    bundle = Cypress::CqlBundleImporter.import(bundle_zip)
    measure = Measure.where({bundle_id: bundle.id}).last()
    patient = Patient.where({bundleId: bundle.id}).last()
    calc_job = Cypress::CqmExecutionCalc.new([patient.qdmPatient],
          [measure],
          bundle.id.to_s,
          'effectiveDateEnd': Time.at(bundle.effective_date).in_time_zone.to_formatted_s(:number),
          'effectiveDate': Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number))
    results = calc_job.execute(false)
    assert_equal (before_measure_count + 2), Measure.count()
    assert_equal (before_value_set_count + 21), ValueSet.count()
    assert_equal (before_patient_count + 1), Patient.count()
  end
end