module TaskRepresenter
  include API::Representer

  property :type, getter: ->(_args) { _type.delete('Task') }

  self.links = {
    self: proc { product_test_task_path(product_test, self) },
    executions: proc { task_test_executions_path(self) },
    most_recent_execution: proc { most_recent_execution ? task_test_execution_path(self, most_recent_execution) : nil }
  }

  self.embedded = {}
end
