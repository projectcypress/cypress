# frozen_string_literal: true

module Validators
  class CMSSchematronValidator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators
    def initialize(schematron_file, name, as_warnings, bundle_version = Settings.current.default_bundle)
      @validator = Schematron::Validator.new(name, schematron_file) if File.exist?(schematron_file)
      @bundle_version = bundle_version
      @as_warnings = as_warnings
    end

    def schematron_folder_for_bundle_version(bundle_version)
      ApplicationController.helpers.config_for_version(bundle_version).schematron
    end

    def validate(file, options = {})
      @options = options
      doc = get_document(file)
      class_name = self.class.to_s.split('::')[-1]
      default_errors = ApplicationController.helpers.config_for_version(@bundle_version)["#{class_name}_warnings"]
      default_errors&.each do |error|
        add_warning error, validator_type: :xml_validation, file_name: @options[:file_name], cms: true
      end
      return unless @validator

      errors = @validator.validate(doc, options)
      type = @as_warnings ? :warning : :error
      errors.each do |error|
        add_issue error.message, type, message: error.message,
                                       location: error.location, validator: error.validator,
                                       validator_type: :xml_validation, file_name: @options[:file_name], cms: true
      end
    end
  end

  class CMSQRDA3SchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = Settings.current.default_bundle, as_warnings: false)
      super(Rails.root.join('resources', 'schematron', schematron_folder_for_bundle_version(bundle_version), 'EP', 'EP_CAT_III.sch').to_s,
            self.class.to_s, as_warnings, bundle_version)
    end
  end

  class CMSQRDA1HQRSchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = Settings.current.default_bundle, as_warnings: false)
      super(Rails.root.join('resources', 'schematron', schematron_folder_for_bundle_version(bundle_version), 'EH', 'EH_CAT_I.sch').to_s,
            self.class.to_s, as_warnings, bundle_version)
    end
  end

  class CMSQRDA1PQRSSchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = Settings.current.default_bundle, as_warnings: false)
      super(Rails.root.join('resources', 'schematron', schematron_folder_for_bundle_version(bundle_version), 'EP', 'EP_CAT_I.sch').to_s,
            self.class.to_s, as_warnings, bundle_version)
    end
  end
end
