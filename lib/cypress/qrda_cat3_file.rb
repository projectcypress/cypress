module Cypress
  class QrdaCat3File < QrdaFile

    SCHEMATRON = APP_CONFIG["validation"]["schematron"]["qrda_cat_3"]

    SCHEMATRON_ERROR_VALIDATOR = Validators::Schematron::UncompiledValidator.new("Generic QRDA Cat III Schematron", SCHEMATRON,ISO_SCHEMATRON,true,{"phase" => "errors"})
    SCHEMATRON_WARNING_VALIDATOR = Validators::Schematron::UncompiledValidator.new("Generic QRDA Cat III Schematron", SCHEMATRON,ISO_SCHEMATRON,true,{"phase" => "warnings"})
    

    # Nothing to see here - Move along
    def validate
      file_errors = []
      file_errors.concat QRDA_SCHEMA_VALIDATOR.validate(@document, {msg_type: :error}) 
      # Valdiate aginst the generic schematron rules
      file_errors.concat SCHEMATRON_ERROR_VALIDATOR.validate(@document, {phase: :errors, msg_type: :error})
      # file_errors.concat QRDA_CAT3_SCHEMATRON_WARNING_VALIDATOR.validate(doc, {phase: :warnings, msg_type: :warning, file_name: name })
      file_errors
    end
    
  end
end