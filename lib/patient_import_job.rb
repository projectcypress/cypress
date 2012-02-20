module Cypress
  # This is Resque job that will create records for a vendor from a ZIP file they upload, filled with C32s.
  # A new PatientImportJob can be created like this:
  #
  #    Cypress::PatientImportJob.create(:zip_file_location => 'path/to/zip/file/of/c32s', :test_id => 'ID of vendor to which these patients belong')
  #
  # This will return a uuid which can be used to check in on the status of a job. More details on this can be found
  # at the {Resque Stats project page}[https://github.com/quirkey/resque-status].
  class PatientImportJob < Resque::JobWithStatus
    def perform
      Zip::ZipFile.foreach(options['zip_file_location']) do |zip_entry|
        if zip_entry.name.include?('.xml') && ! zip_entry.name.include?('__MACOSX')
          doc = Nokogiri::XML(zip_entry.get_input_stream)
          if options['format'] == 'ccr' then
            doc.root.add_namespace_definition('ccr', 'urn:astm-org:CCR')
            patient = HealthDataStandards::Import::CCR::PatientImporter.instance.parse_ccr(doc)
          else
            doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
            patient = HealthDataStandards::Import::C32::PatientImporter.instance.parse_c32(doc)
          end
          
          patient.test_id = options['test_id']
          
          QME::Importer::MeasurePropertiesGenerator.instance.generate_properties!(patient)
        end
      end
      
      File.delete(options['zip_file_location'])
    end
  end
end