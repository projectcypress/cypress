module VendorRepresenter
  include API::Representer

  property :vendor_id
  property :name
  property :url
  property :address
  property :zip
  property :state
  property :created_at
  property :updated_at

  self.embedded = {
    points_of_contact: %i[name email phone contact_type]
  }

  self.links = {
    self: proc { vendor_path(self) },
    products: proc { vendor_products_path(self) }
  }
end
