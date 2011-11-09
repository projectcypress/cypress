require 'builder'

module Cypress
  class PatientZipper
  
    def self.zip(file, patients, format)
      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          safe_first_name = patient.first.gsub("'", '')
          safe_last_name = patient.last.gsub("'", '')
          z.put_next_entry("#{i}_#{safe_first_name}_#{safe_last_name}.xml")
          if format==:c32
            z << HealthDataStandards::Export::C32.export(patient)
          else
            z << HealthDataStandards::Export::CCR.export(patient)
          end
        end
      end
    end
    
  end
end