# frozen_string_literal: true

# require "cypress/qrda_file_validator"

module Validators
  class QrdaUploadValidator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators

    def initialize(year, qrda_type, organization)
      bundle_year = year.to_i - 1

      qrda_validator = case qrda_type
                       when 'qrdaI'
                         qrda_1_validator(bundle_year, organization)
                       when 'qrdaIII'
                         qrda_3_validator(bundle_year, organization)
                       end
      format_validators = [CDA.instance, qrda_validator]
      @validators = format_validators
    end

    def qrda_1_validator(bundle_year, organization)
      return unless [2020, 2021].include? bundle_year

      organization == 'hl7' ? Cat1R52.instance : ::Validators::CMSQRDA1HQRSchematronValidator.new(bundle_year, as_warnings: false)
    end

    def qrda_3_validator(bundle_year, organization)
      return unless [2020, 2021].include? bundle_year

      organization == 'hl7' ? Cat3R21.instance : ::Validators::CMSQRDA3SchematronValidator.new(bundle_year, as_warnings: false)
    end

    def validate(file, options = {})
      @options = options
      doc = get_document(file)

      @validators.each do |validator|
        if validator.class.to_s.split('::')[0] == 'CqmValidators'
          add_cqm_validation_error_as_execution_error(validator.validate(doc, options),
                                                      validator.class.to_s,
                                                      :xml_validation)
        else
          validator.validate(doc, options)
          errors.concat validator.errors
        end
      end
    end
  end
end
