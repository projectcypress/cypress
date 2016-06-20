require 'validators/qrda_cat1_validator'
module Validators
  class QrdaCat3Validator < QrdaFileValidator
    include HealthDataStandards::Validate
    include Validators::Validator

    self.validator = :qrda_cat3

    def initialize(expected_results, test_has_c3)
      @test_has_c3 = test_has_c3
      @expected_results = expected_results
    end

    def validate(file, options = {})
      @doc = file
      @options = options

      # I don't like this right now but do it this way just to get things moving
      if options[:validate_reporting]
        add_errors Cat3PerformanceRate.instance.validate(@doc, file_name: @options[:file_name])
      else
        add_errors Cat3Measure.instance.validate(@doc, file_name: @options[:file_name])
        add_errors Cat3.instance.validate(@doc, file_name: @options[:file_name])
        add_errors CDA.instance.validate(@doc, file_name: @options[:file_name])
      end
    end

    def add_errors(errors)
      # The HDS validators hand back ValidationError objects, but we need ExecutionError objects
      errors.map do |error|
        type = :error
        if error.validator && error.validator.upcase.include?('QRDA') && !@test_has_c3
          type = :warning
        end
        add_issue error.message, type, :location => error.location, :validator => error.validator,
                                       :validator_type => :xml_validation, :file_name => error.file_name
      end
    end
  end
end
