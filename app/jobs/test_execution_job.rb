class TestExecutionJob < ActiveJob::Base
  queue_as :default

  def perform(te, task, options = {})
    te.state = :running
    te.validate_artifact(task.validators, te.artifact, options.merge('test_execution' => te, 'task' => task))
    te.save
  end
end
