# require "cypress/qrda_file_validator"

module Validators
  class QrdaCat1Validator < QrdaFileValidator
    include Validators::Validator

    SCHEMATRON = APP_CONFIG["validation"]["schematron"]["qrda_cat_1"]

    SCHEMATRON_ERROR_VALIDATOR = Validators::Schematron::UncompiledValidator.new("Generic QRDA Cat I Schematron", SCHEMATRON ,ISO_SCHEMATRON,true,{"phase" => "errors"})
    # SCHEMATRON_WARNING_VALIDATOR = Validators::Schematron::UncompiledValidator.new("Generic QRDA Cat I Schematron", SCHEMATRON, ISO_SCHEMATRON,true, {"phase" => "warnings"})

    self.validator_type = :result_validation

    def initialize(measures=[])
      @measures = measures
    end

    # Validates a QRDA Cat I file.  This routine will validate the file against the CDA schema as well as the
    # Generic QRDA Cat I schematron rules and the measure specific rules for each of the measures passed in.
    # THe result will be an Array of execution errors or an empty array if there were no errors.
    def validate(file, name)
      doc = get_document(file)
      # validate that each file in the zip contains a valid QRDA Cat I document.
      # We may in the future have to support looking in the contents of the test
      # patient records to match agaist QRDA Cat I documents
      # First validate the schema correctness
      add_errors QRDA_SCHEMA_VALIDATOR.validate(doc, {msg_type: :error})
      add_errors SCHEMATRON_ERROR_VALIDATOR.validate(doc, {phase: :errors, msg_type: :error, file_name: name})

      @measures.each do |measure|
        # Look in the document to see if there is an entry stating that it is reporting on the given measure
        # we will be a bit lenient and look for both the version specific id and the non version specific ids
        measure_xpath = %Q(//cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.98']]/cda:reference[@typeCode='REFR']/
          cda:externalDocument[@classCode='DOC']/cda:id[#{translate("@root")}='2.16.840.1.113883.4.738' and #{translate("@extension")}='#{measure.hqmf_id.upcase}'])
        if !doc.at_xpath(measure_xpath)
          add_error("Document does not state it is reporting measure #{measure.hqmf_id}  - #{measure.name}",
              {:validator=>"Measure Declaration Check"})
        end
      end
      nil
    end

  end
end
