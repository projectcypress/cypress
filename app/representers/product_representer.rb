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

  self.links = {
    self: Proc.new { vendor_product_path(self.vendor, self) },
    product_tests: Proc.new { product_product_tests_path(self) },
    patients: Proc.new { patients_vendor_product_path(self.vendor, self) }
  }

  self.embedded = {}
end
