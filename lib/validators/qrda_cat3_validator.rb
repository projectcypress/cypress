require 'validators/qrda_cat1_validator'
module Validators
    class QrdaCat3Validator < QrdaFileValidator
        include HealthDataStandards::Validate
        include Validators::Validator

        def initialize(expected_results)
            @expected_results = expected_results
        end

        def validate(file, options={})
            @doc = file
            @options = options
            validation_errors = Cat3.instance.validate(@doc, file_name: @options[:file_name])
            validation_errors.concat Cat3Measure.instance.validate(@doc, file_name: @options[:file_name])
            validation_errors.concat Cat3PerformanceRate.instance.validate(@doc, file_name: @options[:file_name])
            validation_errors.concat CDA.instance.validate(@doc, file_name: @options[:file_name])

            # The HDS validators hand back ValidationError objects, but we need ExecutionError objects
            validation_errors.map do |error|
                add_error(error.message,{:location=>error.location,:validator=>error.validator,:validator_type=>:xml_validation})
            end
        end
    end
end