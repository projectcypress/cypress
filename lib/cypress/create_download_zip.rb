module Cypress
  class CreateDownloadZip
    def self.create_test_zip(test_id, format = 'html')
      pt = ProductTest.find(test_id)
      create_zip(pt.records.to_a, format)
    end

    def self.create_zip(patients, format)
      file = Tempfile.new("patients-#{Time.now.to_i}")
      Cypress::PatientZipper.zip(file, patients, format)
      file
    end

    def self.create_total_test_zip(product)
      file = Tempfile.new("all-patients-#{Time.now.to_i}")
      Cypress::PatientZipper.zip_patients_all_measures(file, product.measure_tests)
      file
    end
  end
end
