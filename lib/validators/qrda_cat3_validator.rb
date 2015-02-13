module Validators
    class QrdaCat3Validator
        include HealthDataStandards::Validate

        def initialize(file, filename)
            @doc = file
            @filename = filename
        end

        def validate
            validation_errors = Cat3.instance.validate(@doc, {file_name: @filename})
            validation_errors.concat CDA.instance.validate(@doc, {file_name: @filename})

            # The HDS validators hand back ValidationError objects, but we need ExecutionError objects
            validation_errors.map do |error|
              ExecutionError.new(location: error.location, message: error.message,
               validator: error.validator, validator_type: :xml_validation, msg_type: :error)
            end
        end
    end
end