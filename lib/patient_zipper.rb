require 'builder'

module Cypress
  class PatientZipper
  
    def self.zip(file, patients, format)
      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          z.put_next_entry("#{i}_#{patient.first}_#{patient.last}.xml")
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