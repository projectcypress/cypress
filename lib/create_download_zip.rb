module Cypress
  class CreateDownloadZip
    require 'patient_zipper'

    def self.create_patient_zip(record_id, format)
      if record_id
        patients = Record.where("_id" => record_id)
      else
        patients = Record.where("test_id" => nil)
      end
      create_zip(patients,format)
    end

    def self.create_test_zip(test_id, format)
      create_zip(Record.where("test_id" => test_id),format)
    end

    def self.create_zip(patients, format)
      file = Tempfile.new("patients-#{Time.now.to_i}")
      #file = File.new("/tmp/patients-#{Time.now.to_i}","w")
      
      if format == 'csv'
        Cypress::PatientZipper.flat_file(file, patients)
      else
        Cypress::PatientZipper.zip(file, patients, format.to_sym)
      end
      
      return file
    end
  end
end