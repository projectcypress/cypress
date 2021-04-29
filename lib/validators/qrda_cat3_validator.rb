# frozen_string_literal: true

require 'validators/qrda_cat1_validator'
module Validators
  class QrdaCat3Validator < QrdaFileValidator
    include ::CqmValidators

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
      # TODO update Cat3PerformanceRate
      if @is_c3_validation_task
        add_cqm_validation_error_as_execution_error(Cat3PerformanceRate.instance.validate(@doc, file_name: @options[:file_name]),
                                                    'CqmValidators::Cat3PerformanceRate',
                                                    :xml_validation)
      end
      # Add if it isn't C3 or if it is and there isn't a C2
      return unless !@is_c3_validation_task || (@is_c3_validation_task && !@test_has_c2)

      add_cqm_validation_error_as_execution_error(Cat3Measure.instance.validate(@doc, file_name: @options[:file_name]),
                                                  'CqmValidators::Cat3Measure',
                                                  :xml_validation)
      add_cqm_validation_error_as_execution_error(Cat3R21.instance.validate(@doc, file_name: @options[:file_name]),
                                                  'CqmValidators::Cat3R21',
                                                  :xml_validation)
      add_cqm_validation_error_as_execution_error(CDA.instance.validate(@doc, file_name: @options[:file_name]),
                                                  'CqmValidators::CDA',
                                                  :xml_validation)
    end
  end
end
