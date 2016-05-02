class ProductTestSetupJob < ActiveJob::Base
  queue_as :product_test_setup
  include Job::Status
  def perform(product_test)
    product_test.building
    product_test.generate_records if product_test.records.count == 0
    product_test.pick_filter_criteria if product_test.is_a? FilteringTest
    if product_test.respond_to? :patient_cache_filter
      MeasureEvaluationJob.perform_now(product_test, 'filters' => product_test.patient_cache_filter)
    else
      MeasureEvaluationJob.perform_now(product_test, {})
    end
    product_test.archive_records if product_test.patient_archive.filename.nil?
    product_test.ready
  end
end
