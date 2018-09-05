require 'test_helper'

class MeasureEvaluationJobTest < ActiveJob::TestCase
  def setup
    vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    @product = vendor.products.create(name: 'test_product', c2_test: true, randomize_patients: true, bundle_id: @bundle.id,
                                      measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
  end

  def test_can_queue_product_test_job
    assert_enqueued_jobs 0
    MeasureEvaluationJob.perform_later(ProductTest.new(measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']), {})
    assert_enqueued_jobs 1
  end

  def test_can_queue_task_job
    assert_enqueued_jobs 0
    ptest = ProductTest.new(measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    task = ptest.tasks.build({}, C1Task)
    MeasureEvaluationJob.perform_later(task, {})
    assert_enqueued_jobs 1
  end

  def test_can_run_product_test_job
    assert_enqueued_jobs 0
    perform_enqueued_jobs do
      ptest = @product.product_tests.create({ name: 'test_for_measure_job_calculation',
                                              measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
      assert_performed_jobs 1
      ptest.reload
      assert_not ptest.expected_results.empty?
      assert_equal ptest.expected_results.keys, ['BE65090C-EB1F-11E7-8C3F-9A214CF093AEa']
    end
  end

  def test_can_run_task_job
    assert_enqueued_jobs 0
    perform_enqueued_jobs do
      ptest = @product.product_tests.create({ name: 'test_for_measure_job_calculation',
                                              measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
      task = ptest.tasks.create({})
      MeasureEvaluationJob.perform_later(task, {})
      assert_performed_jobs 2
      task.reload
      assert_not task.expected_results.empty?
      assert_equal task.expected_results.keys, ['BE65090C-EB1F-11E7-8C3F-9A214CF093AEa']
    end
  end
end
