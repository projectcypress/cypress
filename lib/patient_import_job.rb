module Cypress
  class PatientImportJob < Resque::JobWithStatus
    
    def perform
      Zip::ZipFile.foreach(options['zip_file_location']) do |zip_entry|
        if zip_entry.name.include?('.xml') && ! zip_entry.name.include?('__MACOSX')
          doc = Nokogiri::XML(zip_entry.get_input_stream)
          doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
          patient = HealthDataStandards::Import::C32::PatientImporter.instance.parse_c32(doc)
          patient.test_id = options['test_id']
          QME::Importer::MeasurePropertiesGenerator.instance.generate_properties!(patient)
        end
      end
    end
  end
end