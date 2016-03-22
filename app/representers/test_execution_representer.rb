module TestExecutionRepresenter
  include API::Representer

  property :state
  property :execution_errors
  property :created_at
  property :updated_at
  property :sibling_execution_id

  self.links = {
    self: Proc.new { task_test_execution_path(self.task, self) }
  }

  self.embedded = {
    execution_errors: [:file_name, :location, :message, :msg_type, :stratification, :validator_type, :validator]
  }
end