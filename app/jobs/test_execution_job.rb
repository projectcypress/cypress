class TestExecutionJob < ActiveJob::Base
  include Job::Status
  queue_as :default

  after_enqueue do|job|
    job.tracker.set_options(test_execution_id: job.arguments[0].id,
                            task_id: job.arguments[1].id)
  end
  def perform(te, task, options = {})
    te.state = :running
    te.validate_artifact(task.validators, te.artifact, options.merge('test_execution' => te, 'task' => task))
    te.save
  end
end
