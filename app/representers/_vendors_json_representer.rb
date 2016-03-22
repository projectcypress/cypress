module VendorsJsonRepresenter
  # include Roar::JSON::HAL

  # collection 'vendors', extend: VendorJsonRepresenter, embedded: true
  include Representable::JSON::Collection

  items extend: VendorJsonRepresenter

  # link :self do
  #   vendors_path
  # end
end