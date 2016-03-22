module VendorRepresenter
  include API::Representer

  property :name
  property :created_at
  property :address
  property :state
  property :updated_at
  property :url
  property :vendor_id
  property :zip

  self.links = {
    self: Proc.new { vendor_path(self) },
    products: Proc.new { vendor_products_path(self) }
  }

  self.embedded = {
    pocs: [:name, :email, :phone, :contact_type]
  }
end