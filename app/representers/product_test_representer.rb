module ProductTestRepresenter
  include API::Representer

  property :name
  property :cms_id
  property :created_at
  property :updated_at
  property :description
  property :measure_id, getter: lambda { |args| self.measure_ids.first }
  property :state
  property :status_message
  property :type, getter: lambda { |args| self._type == 'MeasureTest' ? 'measure' : 'filter' }

  self.links = {
    self: Proc.new { product_product_test_path(self.product, self) },
    tasks: Proc.new { product_test_tasks_path(self) },
    patients: Proc.new { patients_product_test_path(self) }
  }

  self.embedded = {}
end