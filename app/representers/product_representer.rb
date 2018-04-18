module ProductRepresenter
  include API::Representer

  property :name
  property :version
  property :description
  property :c1_test
  property :c2_test
  property :c3_test
  property :c4_test
  property :randomize_patients
  property :duplicate_patients
  collection :measure_ids
  property :created_at
  property :updated_at

  self.collections = {
    # key is collection name, value is element name for XML only
    measure_ids: 'measure_id'
  }

  self.links = {
    self: proc { vendor_product_path(vendor, self) },
    product_tests: proc { product_product_tests_path(self) },
    patients: proc { patients_vendor_product_path(vendor, self) }
  }
end
