require 'test_helper'

class MeasureEvaluationJobTest < ActiveJob::TestCase
  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @result = QME::QualityReportResult.new(DENOM: 48, NUMER: 44, antinumerator: 4, DENEX: 0)
  end

  def test_can_queue_product_test_job
    assert_enqueued_jobs 0
    MeasureEvaluationJob.perform_later(ProductTest.new(measure_ids: ['8A4D92B2-3887-5DF3-0139-0C4E41594C98']), {})
    assert_enqueued_jobs 1
  end

  def test_can_queue_task_job
    assert_enqueued_jobs 0
    ptest = ProductTest.new(measure_ids: ['8A4D92B2-3887-5DF3-0139-0C4E41594C98'])
    task = ptest.tasks.build({}, C4Task)
    MeasureEvaluationJob.perform_later(task, {})
    assert_enqueued_jobs 1
  end

  def test_can_run_product_test_job
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)
    assert_enqueued_jobs 0
    prod = Product.first
    perform_enqueued_jobs do
      ptest = prod.product_tests.create(name: 'test_for_measure_job_calculation',
                                        measure_ids: ['8A4D92B2-3887-5DF3-0139-0C4E41594C98'],
                                        bundle_id: '4fdb62e01d41c820f6000001')
      assert_performed_jobs 1
      ptest.reload
      assert !ptest.expected_results.empty?
      assert_equal ptest.expected_results.keys, ['8A4D92B2-3887-5DF3-0139-0C4E41594C98a',
                                                 '8A4D92B2-3887-5DF3-0139-0C4E41594C98b',
                                                 '8A4D92B2-3887-5DF3-0139-0C4E41594C98c',
                                                 '8A4D92B2-3887-5DF3-0139-0C4E41594C98d']
    end
  end

  def test_can_run_task_job
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)
    assert_enqueued_jobs 0
    prod = Product.first
    perform_enqueued_jobs do
      ptest = prod.product_tests.create(name: 'test_for_measure_job_calculation',
                                        measure_ids: ['8A4D92B2-3887-5DF3-0139-0C4E41594C98'],
                                        bundle_id: '4fdb62e01d41c820f6000001')
      task = ptest.tasks.create({})
      MeasureEvaluationJob.perform_later(task, {})
      assert_performed_jobs 2
      task.reload
      assert !task.expected_results.empty?
      assert_equal task.expected_results.keys, ['8A4D92B2-3887-5DF3-0139-0C4E41594C98a',
                                                '8A4D92B2-3887-5DF3-0139-0C4E41594C98b',
                                                '8A4D92B2-3887-5DF3-0139-0C4E41594C98c',
                                                '8A4D92B2-3887-5DF3-0139-0C4E41594C98d']
    end
  end
end
