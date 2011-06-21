require 'builder'

module Cypress
  class PatientZipper
  
    def self.zip(file, patients, format)
      Zip::ZipOutputStream.open(file.path) do |z|
        patients.each_with_index do |patient, i|
          z.put_next_entry("#{i}_#{patient.first}_#{patient.last}.xml")
          xml = Builder::XmlMarkup.new(:indent => 2)
          xml.instruct!
          if format==:c32
            z << patient.to_c32(xml)
          else
            z << patient.to_ccr(xml)
          end
        end
      end
    end
    
  end
end