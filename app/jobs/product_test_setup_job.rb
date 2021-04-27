class ProductTestSetupJob < ApplicationJob
  queue_as :product_test_setup
  include Job::Status
  def perform(product_test)
    product_test.building
    product_test.generate_patients(@job_id) if product_test.patients.count.zero?
    calculate_product_test(product_test)
    MeasureEvaluationJob.perform_now(product_test, {})
    product_test.archive_patients if product_test.patient_archive.path.nil?
    product_test.ready
  rescue StandardError => e
    product_test.backtrace = e.backtrace.join("\n")
    product_test.status_message = error_message(e)
    product_test.errored
    product_test.save!
  end

  def calculate_product_test(product_test)
    if product_test.is_a? FilteringTest
      product_test.pick_filter_criteria
      unfiltered_patients = product_test.patients
      # Perform calculation for unfiltered patient list, this is used for patient list view only.
      do_calculation(product_test, unfiltered_patients, "#{product_test._id}_unfiltered")
      patients = product_test.filtered_patients
    else
      patients = product_test.patients
    end
    do_calculation(product_test, patients, product_test._id.to_s)
  end

  def do_calculation(product_test, patients, correlation_id)
    effective_date = Time.at(product_test.measure_period_start).in_time_zone.to_formatted_s(:number)
    patient_ids = patients.map { |p| p.id.to_s }
    options = { 'effectiveDate': effective_date }
    product_test.measures.map do |measure|
      SingleMeasureCalculationJob.perform_now(patient_ids, measure.id.to_s, correlation_id, options)
    end.flatten
  end

  private

  def error_message(error)
    "#{error.message} on #{error.backtrace.first.remove(Rails.root.to_s)}"
  end
end
