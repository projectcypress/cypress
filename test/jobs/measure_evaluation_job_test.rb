require 'test_helper'

class MeasureEvaluationJobTest < ActiveJob::TestCase
  def setup
    vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    @result = QME::QualityReportResult.new(DENOM: 48, NUMER: 44, antinumerator: 4, DENEX: 0)
    @product = vendor.products.create(name: 'test_product', c2_test: true, randomize_patients: false, bundle_id: @bundle.id,
                                      measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
  end

  def test_can_use_sync_and_async_results
    pt = @product.product_tests.build({ name: 'test_for_measure_1a', bundle_id: @bundle.id,
                                        measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    perform_enqueued_jobs do
      pt.save
      pt.reload
      # clear out expected_results created with product test
      pt.expected_results = nil

      correlation_id = BSON::ObjectId.new.to_s
      calc_job = Cypress::CqmExecutionCalc.new(pt.patients, pt.measures, pt.value_sets_by_oid, correlation_id,
                                               'effectiveDateEnd': Time.at(pt.effective_date).in_time_zone.to_formatted_s(:number),
                                               'effectiveDate': Time.at(pt.measure_period_start).in_time_zone.to_formatted_s(:number))
      individual_results_from_sync_job = calc_job.execute

      # calculate expected_results using individual results stored in database (don't pass in individual results)
      MeasureEvaluationJob.perform_now(pt, {})
      db_expected_results = pt.expected_results

      pt.expected_results = nil

      # calculate expected_results using individual results returned from sync_job (pass in individual results)
      MeasureEvaluationJob.perform_now(pt, individual_results: individual_results_from_sync_job)
      sync_job_expected_results = pt.expected_results

      assert_equal db_expected_results, sync_job_expected_results
    end
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
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)
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
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)
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
