module VendorsXmlRepresenter
  include Roar::XML
  # include Roar::Hypermedia
  include Representable::XML::Collection

  items extend: VendorXmlRepresenter, wrap: :vendors

  # collection 'vendors', extend: VendorXmlRepresenter, as: :vendor, wrap: :vendors

  # link :self do
  #   vendors_path
  # end
end