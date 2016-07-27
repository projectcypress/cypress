class ProductTestSetupJob < ActiveJob::Base
  queue_as :product_test_setup
  include Job::Status
  def perform(product_test)
    begin
      product_test.building
      asdfasdfasdf
      product_test.generate_provider if product_test.is_a? MeasureTest
      product_test.generate_records if product_test.records.count == 0
      product_test.pick_filter_criteria if product_test.is_a? FilteringTest
      if product_test.respond_to? :patient_cache_filter
        MeasureEvaluationJob.perform_now(product_test, 'filters' => product_test.patient_cache_filter)
      else
        MeasureEvaluationJob.perform_now(product_test, {})
      end
      product_test.archive_records if product_test.patient_archive.filename.nil?
      product_test.ready
    rescue StandardError => e
      require 'pry'
      binding.pry
      product_test.tasks.each do |task|
        task.test_executions << TestExecution.create!(state => :errored)
        task.save!
      end
      product_test.status_message = e.message
      product_test.errored
    end
  end
end
