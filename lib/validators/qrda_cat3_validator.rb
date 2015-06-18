module Validators
    class QrdaCat3Validator
        include HealthDataStandards::Validate

        def initialize(file, filename, expected_results)
            @doc = file
            @filename = filename
            @expected_results = expected_results
        end

        def validate
            validation_errors = Cat3.instance.validate(@doc, {file_name: @filename})
            validation_errors.concat Cat3Measure.instance.validate(@doc, {file_name: @filename})
            validation_errors.concat Cat3PerformanceRate.instance.validate(@doc, {file_name: @filename})
            validation_errors.concat CDA.instance.validate(@doc, {file_name: @filename})

            # The HDS validators hand back ValidationError objects, but we need ExecutionError objects
            validation_errors.map do |error|
              ExecutionError.new(location: error.location, message: error.message,
               validator: error.validator, validator_type: :xml_validation, msg_type: :error)
            end
        end
    end
end