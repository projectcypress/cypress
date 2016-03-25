module BundleRepresenter
  include API::Representer

  property :title
  property :version

  self.links = {
    self: proc { bundle_path(self) },
    measures: proc { bundle_measures_path(self) }
  }

  self.embedded = {}
end
