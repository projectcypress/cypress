# frozen_string_literal: true

module BundleRepresenter
  include Api::Representer

  property :title
  property :version

  self.links = {
    self: proc { bundle_path(self) },
    measures: proc { bundle_measures_path(self) }
  }
end
