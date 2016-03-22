module VendorXmlRepresenter
  include Roar::XML
  include Roar::Hypermedia
  include VendorBaseRepresenter

  collection :pocs, extend: PocXmlRepresenter, as: :poc, wrap: :points_of_contact

  link :products do
    vendor_products_path(self)
  end

  link :self do
    vendor_path(self)
  end
end