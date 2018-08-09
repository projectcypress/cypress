class ProductTestSetupJob < ApplicationJob
  queue_as :product_test_setup
  include Job::Status
  def perform(product_test)
    product_test.building
    product_test.generate_provider if product_test.is_a? MeasureTest
    product_test.generate_patients(@job_id) if product_test.patients.count.zero?
    results = calculate_product_test(product_test)
    MeasureEvaluationJob.perform_now(product_test, individual_results: results)
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
    measures = product_test.measures
    # value_sets = product_test.bundle.value_sets.in(:oid.in => measures.collect(&:oids).flatten.uniq)
    # value_set_map = {}
    # value_sets.each do |vs|
    #   if !value_set_map.key?(vs['oid'])
    #     value_set_map[vs['oid']] = {}
    #   end
    #   value_set_map[vs['oid']][vs['version']] = vs
    # end
    # value_sets_by_oid_json = MultiJson.encode value_set_map
    calc_job = Cypress::JsEcqmCalc.new('correlationId': correlation_id,
                                       'effectiveDate': Time.at(product_test.effective_date).in_time_zone.to_formatted_s(:number))
    calc_job.request(patients, measures.first)
  end

  private

  def error_message(error)
    error.message + ' on ' + error.backtrace.first.remove(Rails.root.to_s)
  end
end
