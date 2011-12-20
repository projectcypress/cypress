module Cypress
  class PatientImportJob < Resque::JobWithStatus
    
    # TODO: Need to add in the test id
    # TODO: Need to run through the property matching/denormalization logic
    def perform
      Zip::ZipFile.foreach(options['zip_file_location']) do |zip_entry|
        if zip_entry.name.include?('.xml') && ! zip_entry.name.include?('__MACOSX')
          doc = Nokogiri::XML(zip_entry.get_input_stream)
          doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
          patient = HealthDataStandards::Import::C32::PatientImporter.instance.parse_c32(doc)
          patient.save!
        end
      end
    end
  end
end