module ProductTestRepresenter
  include API::Representer

  property :name
  property :cms_id
  property :measure_id, getter: ->(_args) { measure_ids.first }
  property :type, getter: ->(_args) { _type == 'MeasureTest' ? 'measure' : 'filter' }
  property :state

  self.links = {
    self: proc { product_product_test_path(product, self) },
    tasks: proc { product_test_tasks_path(self) },
    patients: proc { patients_product_test_path(self) }
  }
end
