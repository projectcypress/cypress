require 'test_helper'

class TestExecutionJobTest < ActiveJob::TestCase
  def setup
    @ptest = FactoryGirl.create(:product_test_static_result)
  end

  def test_can_queue_job
    assert_enqueued_jobs 2

    #ptest = ProductTest.find('51703a4e3054cf8439000004')
    task = @ptest.tasks.create({}, C2Task)
    te = task.test_executions.create({})

    job = TestExecutionJob.perform_later(te, task)

    assert_not_nil job.tracker, 'should have created a tracker for the job'
    assert_equal job.arguments[0].id, job.tracker.options[:test_execution_id], 'tracker should have set options for test execution id'
    assert_equal :queued, job.tracker.status, 'current status should be queued'
    assert_enqueued_jobs 3
  end

  def test_can_run_job
    assert_enqueued_jobs 2

    #ptest = ProductTest.find('51703a6a3054cf8439000044')
    @ptest.product.c2_test = true
    task = @ptest.tasks.create({}, C2Task)
    te = task.test_executions.create({})

    # test file known to have errors
    test_file = create_rack_test_file('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_missing_supplemental.xml', 'application/xml')
    te.artifact = Artifact.new(file: test_file)
    te.save

    assert te.incomplete?, 'test execution should be incomplete before it is run'

    TestExecutionJob.perform_now(te, task)

    assert_enqueued_jobs 2

    assert !te.incomplete?, 'test execution should not be incomplete after it is run'
    assert te.failing?, 'test execution with bad file should fail'
    assert te.execution_errors.only_errors.count > 0, 'test execution should have errors'
  end
end
