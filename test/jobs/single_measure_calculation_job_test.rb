# frozen_string_literal: true

require 'test_helper'

class SingleMeasureCalculationJobTest < ActiveJob::TestCase
  def setup
    @bundle = FactoryBot.create(:executable_bundle)
    @patient = BundlePatient.create(givenNames: ['Patient'], familyName: 'Test', bundleId: @bundle.id)
    @patient.qdmPatient.birthDatetime = DateTime.new(1985, 2, 18).utc
    @patient.qdmPatient.dataElements << QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['races'].sample['code'], 'system' => '2.16.840.1.113883.6.238' }])
    @patient.qdmPatient.dataElements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => APP_CONSTANTS['randomization']['ethnicities'].sample['code'], 'system' => '2.16.840.1.113883.6.238' }])
    @patient.qdmPatient.dataElements << QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => 'M', 'system' => '2.16.840.1.113883.5.1' }])
    @patient.qdmPatient.dataElements << QDM::EncounterPerformed.new(relevantPeriod: QDM::Interval.new(DateTime.new(2017, 9, 28, 8, 0, 0).utc, DateTime.new(2017, 9, 28, 8, 30, 0).utc),
                                                                    dataElementCodes: [{ 'code' => '720', 'system' => '2.16.840.1.113883.6.96' }])
  end

  def test_run_calcs_with_56_bundle
    @bundle.update(version: '2022.0.0')
    measure = @bundle.measures.first
    effective_date = Time.at(@bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
    options = { 'effectiveDate' => effective_date }
    perform_enqueued_jobs do
      SingleMeasureCalculationJob.perform_now([@patient.id.to_s], measure.id.to_s, 'what', options)
      assert @patient.calculation_results.size.positive?
    end
  end
end
