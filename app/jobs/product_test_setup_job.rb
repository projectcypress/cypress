# frozen_string_literal: true

class ProductTestSetupJob < ApplicationJob
  queue_as :product_test_setup
  include Job::Status
  def perform(product_test)
    product_test.building
    # Try to build a test deck.  Retry 5 times if a test deck results in an IPP of 0
    5.times do
      product_test.generate_patients(@job_id) if product_test.patients.count.zero?
      results = calculate_product_test(product_test)
      break if results.any? { |result| result.IPP.positive? }

      Patient.delete_all(correlation_id: product_test.id)
      product_test.rand_seed = Random.new_seed.to_s
      product_test.save!
      product_test.reload
    end
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
    effective_date = product_test.start_date.to_formatted_s(:number)
    patient_ids = patients.map { |p| p.id.to_s }
    options = { effectiveDate: effective_date }
    # If the product_test start_date is january 1st, you don't need to pass in the effectiveDateEnd, the calculation engine will take care of it
    options[:effectiveDateEnd] = product_test.end_date.to_formatted_s(:number) if product_test.start_date.yday != 1
    product_test.measures.map do |measure|
      SingleMeasureCalculationJob.perform_now(patient_ids, measure.id.to_s, correlation_id, options)
    end.flatten
  end

  private

  def error_message(error)
    "#{error.message} on #{error.backtrace.first.remove(Rails.root.to_s)}"
  end
end
