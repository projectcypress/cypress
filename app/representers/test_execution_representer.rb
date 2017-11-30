module TestExecutionRepresenter
  include API::Representer

  property :state
  property :execution_errors
  property :created_at

  self.links = {
    self: proc { task_test_execution_path(task, self) },
    sibling_execution: proc { sibling_execution ? task_test_execution_path(sibling_execution.task, sibling_execution) : nil }
  }

  self.embedded = {
    execution_errors: %i[file_name location message msg_type stratification validator_type validator]
  }
end
