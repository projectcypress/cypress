class BundleCalculationJob < ApplicationJob
  queue_as :bundle_calculation
  include Job::Status

  def perform(bundle_id, measure_id)
    bundle = Bundle.find(bundle_id)
    measure = Measure.find(measure_id)
    qdm_patients = bundle.patients.map(&:qdmPatient)
    calc_job = Cypress::CqmExecutionCalc.new(qdm_patients,
                                             [measure],
                                             bundle.id.to_s,
                                             'effectiveDateEnd': Time.at(bundle.effective_date).in_time_zone.to_formatted_s(:number),
                                             'effectiveDate': Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number))
    calc_job.execute(true)
  end
end
