module VendorJsonRepresenter
  include Roar::JSON::HAL
  include VendorBaseRepresenter

  collection :pocs, extend: PocJsonRepresenter

  link :products do
    vendor_products_path(self)
  end

  link :self do
    vendor_path(self)
  end
end