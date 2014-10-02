module Cypress
  class QrdaCat1File < QrdaFile

    SCHEMATRON = APP_CONFIG["validation"]["schematron"]["qrda_cat_1"]

    SCHEMATRON_ERROR_VALIDATOR = Validators::Schematron::UncompiledValidator.new("Generic QRDA Cat I Schematron", SCHEMATRON ,ISO_SCHEMATRON,true,{"phase" => "errors"})
    SCHEMATRON_WARNING_VALIDATOR = Validators::Schematron::UncompiledValidator.new("Generic QRDA Cat I Schematron", SCHEMATRON, ISO_SCHEMATRON,true, {"phase" => "warnings"})
  
    # Validates a QRDA Cat I file.  This routine will validate the file against the CDA schema as well as the 
    # Generic QRDA Cat I schematron rules and the measure specific rules for each of the measures passed in.
    # THe result will be an Array of execution errors or an empty array if there were no errors.
    def validate(measures=[], name="")

      file_errors = []
       # validate that each file in the zip contains a valid QRDA Cat I document.
       # We may in the future have to support looking in the contents of the test 
       # patient records to match agaist QRDA Cat I documents
       
       # First validate the schema correctness
       file_errors.concat QRDA_SCHEMA_VALIDATOR.validate(@document, {msg_type: :error}) 

        # Valdiate aginst the generic schematron rules
        file_errors.concat SCHEMATRON_ERROR_VALIDATOR.validate(@document, {phase: :errors, msg_type: :error, file_name: name})
        # file_errors.concat QRDA_CAT1_SCHEMATRON_WARNING_VALIDATOR.validate(doc, {phase: :warnings, msg_type: :warning, file_name: name })

        # validate the mesure specific rules
        measures.each do |measure|
          # Look in the document to see if there is an entry stating that it is reporting on the given measure
          # we will be a bit lieniant and look for both the version specific id and the non version specific ids
          if !@document.at_xpath("//cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.98']]/cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']/cda:id[#{translate("@extension")}='#{measure.hqmf_id.upcase}']")
            file_errors << ExecutionError.new(:location=>"/", :msg_type=>"error", :message=>"Document does not state it is reporting measure #{measure.hqmf_id}  - #{measure.name}", :validator=>"Measure Declaration Check")

          end
        end

        file_errors
    end

  end
end