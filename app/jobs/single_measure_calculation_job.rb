# frozen_string_literal: true

class SingleMeasureCalculationJob < ApplicationJob
  queue_as :measure_calculation
  include Job::Status

  def perform(patient_ids, measure_id, correlation_id, options)
    measure = Measure.find(measure_id)
    patients = Patient.find(patient_ids)
    qdm_patients = patients.map do |patient|
      patient.normalize_date_times
      patient.qdmPatient
    end
    calc_job = Cypress::CqmExecutionCalc.new(qdm_patients,
                                             [measure],
                                             correlation_id,
                                             options)
    results = calc_job.execute(save: true)
    patients.map(&:denormalize_date_times)
    results
  end
end
