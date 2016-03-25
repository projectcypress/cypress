module ProductRepresenter
  include API::Representer

  property :name
  property :version
  property :description
  property :c1_test
  property :c2_test
  property :c3_test
  property :c4_test
  property :randomize_records
  property :duplicate_records
  property :measure_ids
  property :created_at
  property :updated_at

  self.links = {
    self: proc { vendor_product_path(vendor, self) },
    product_tests: proc { product_product_tests_path(self) },
    patients: proc { patients_vendor_product_path(vendor, self) }
  }

  self.embedded = {}
end
