class ProductTestSetupJob < ActiveJob::Base
  queue_as :product_test_setup
  include Job::Status
  def perform(product_test)
    product_test.building
    product_test.generate_provider if product_test.is_a? MeasureTest
    product_test.generate_records(@job_id) if product_test.records.count == 0
    product_test.pick_filter_criteria if product_test.is_a? FilteringTest
    if product_test.respond_to? :patient_cache_filter
      MeasureEvaluationJob.perform_now(product_test, 'filters' => product_test.patient_cache_filter)
    else
      MeasureEvaluationJob.perform_now(product_test, {})
    end
    product_test.archive_records if product_test.patient_archive.path.nil?
    product_test.ready
  rescue StandardError => e
    product_test.status_message = e.message
    product_test.errored
    product_test.save!
  end
end
