class TestExecutionJob < ApplicationJob
  include Job::Status
  queue_as :default

  after_enqueue do |job|
    job.tracker.add_options(test_execution_id: job.arguments[0].id,
                            task_id: job.arguments[1].id)
  end
  def perform(test_execution, task, options = {})
    test_execution.state = :running
    test_execution.validate_artifact(task.validators, test_execution.artifact, options.merge('test_execution' => test_execution, 'task' => task))
    test_execution.save
  end
end
