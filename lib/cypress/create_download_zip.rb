module Cypress

  class CreateDownloadZip


    def self.create_patient_zip(record_id, format)

      if record_id
        patients = Record.where("_id" => record_id)
      else
        patients = Record.where("test_id" => nil)
      end
      create_zip(patients,format)
    end

    def self.create_test_zip(test_id, format="html")
      pt = ProductTest.find(test_id)
      create_zip(pt.records,format)
    end

    def self.create_zip(patients, format)
       file = Tempfile.new("patients-#{Time.now.to_i}")
       Cypress::PatientZipper.zip(file, patients, format)
      return file
    end
  end
end
