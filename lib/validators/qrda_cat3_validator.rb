require 'validators/qrda_cat1_validator'
module Validators
  class QrdaCat3Validator < QrdaFileValidator
    include HealthDataStandards::Validate
    include Validators::Validator

    self.validator = :qrda_cat3

    def initialize(expected_results, is_c3_validation_task, test_has_c3, test_has_c2, bundle)
      @bundle = bundle
      @is_c3_validation_task = is_c3_validation_task
      @test_has_c3 = test_has_c3
      @test_has_c2 = test_has_c2
      @expected_results = expected_results
    end

    def validate(file, options = {})
      @doc = get_document(file)
      @options = options

      # I don't like this right now but do it this way just to get things moving
      if @is_c3_validation_task
        add_errors Cat3PerformanceRate.instance.validate(@doc, file_name: @options[:file_name])
      end
      # Add if it isn't C3 or if it is and there isn't a C2
      if !@is_c3_validation_task || (@is_c3_validation_task && !@test_has_c2)
        add_errors Cat3Measure.instance.validate(@doc, file_name: @options[:file_name])
        validate_qrda
        add_errors CDA.instance.validate(@doc, file_name: @options[:file_name])
      end
    end

    def validate_qrda
      if @bundle.qrda3_version == 'r1'
        add_errors Cat3.instance.validate(@doc, file_name: @options[:file_name])
      elsif @bundle.qrda3_version == 'r1_1'
        add_errors Cat3R11.instance.validate(@doc, file_name: @options[:file_name])
      elsif @bundle.qrda3_version == 'r2'
        add_errors Cat3R2.instance.validate(@doc, file_name: @options[:file_name])
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
