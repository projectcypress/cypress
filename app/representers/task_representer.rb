module TaskRepresenter
  include API::Representer

  property :type, getter: lambda { |args| self._type.delete('Task') }

  self.links = {
    self: Proc.new { product_test_task_path(self.product_test, self) },
    executions: Proc.new { task_test_executions_path(self) },
    most_recent_execution: Proc.new { self.most_recent_execution ? task_test_execution_path(self, self.most_recent_execution) : nil }
  }

  self.embedded = {}
end
