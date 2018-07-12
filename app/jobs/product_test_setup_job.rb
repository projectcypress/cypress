class ProductTestSetupJob < ApplicationJob
  queue_as :product_test_setup
  include Job::Status
  def perform(product_test)
    product_test.building
    product_test.generate_provider if product_test.is_a? MeasureTest
    # TODO: R2P: records to patients name
    product_test.generate_patients(@job_id) if product_test.patients.count.zero?
    # product_test.pick_filter_criteria if product_test.is_a? FilteringTest #TODO R2P: priority 4
    if product_test.is_a? FilteringTest
      product_test.pick_filter_criteria
      patient_ids = product_test.filtered_patients.map { |rec| rec._id.to_s }
    else
      patient_ids = product_test.patients.map { |rec| rec._id.to_s }
    end
    do_calculation(product_test, patient_ids)
    # if product_test.respond_to? :patient_cache_filter
    #   MeasureEvaluationJob.perform_now(product_test, 'filters' => product_test.patient_cache_filter)
    # else
    MeasureEvaluationJob.perform_now(product_test, {})
    # end
    product_test.archive_patients if product_test.patient_archive.path.nil?
    product_test.ready
  rescue StandardError => e
    product_test.backtrace = e.backtrace.join("\n")
    product_test.status_message = error_message(e)
    product_test.errored
    product_test.save!
  end

  def do_calculation(product_test, patient_ids)
    calc_job = Cypress::JsEcqmCalc.new('correlation_id': product_test._id.to_s,
                                       'effective_date': Time.at(product_test.effective_date).in_time_zone.to_formatted_s(:number))
    calc_job.sync_job(patient_ids, product_test.measures.map { |mes| mes._id.to_s })
    calc_job.stop
  end

  private

  def error_message(error)
    error.message + ' on ' + error.backtrace.first.remove(Rails.root.to_s)
  end
end
