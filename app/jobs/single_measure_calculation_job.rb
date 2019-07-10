class SingleMeasureCalculationJob < ApplicationJob
  queue_as :measure_calculation
  include Job::Status

  def perform(patient_ids, measure_id, correlation_id, options)
    measure = Measure.find(measure_id)
    patients = Patient.find(patient_ids)
    qdm_patients = patients.map(&:qdmPatient)
    calc_job = Cypress::CqmExecutionCalc.new(qdm_patients,
                                             [measure],
                                             correlation_id,
                                             options)
    calc_job.execute(true)
  end
end
