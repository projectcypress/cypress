module ProductsRepresenter
  include Roar::JSON::HAL

  collection 'products', extend: ProductRepresenter, embedded: true

  link :self do
    vendor_products_path(self.vendor)
  end
end