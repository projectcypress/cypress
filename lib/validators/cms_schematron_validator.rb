module Validators
  class CMSSchematronValidator < QrdaFileValidator
    include Validators::Validator
    include HealthDataStandards::Validate

    self.validator = :cms_schematron
    @bundle_version = Cypress::AppConfig['default_bundle']

    def initialize(schematron_file, name, bundle_version = Cypress::AppConfig['default_bundle'])
      @validator = Schematron::Validator.new(name, schematron_file) if File.exist?(schematron_file)
      @bundle_version = bundle_version
    end

    def schematron_folder_for_bundle_version(bundle_version)
      ApplicationController.helpers.config_for_version(bundle_version).schematron
    end

    def validate(file, options = {})
      @options = options
      doc = get_document(file)
      class_name = self.class.to_s.split('::')[-1]
      default_errors = ApplicationController.helpers.config_for_version(@bundle_version)["#{class_name}_warnings"]
      if default_errors
        default_errors.each do |error|
          add_warning error, :validator_type => :xml_validation, :file_name => @options[:file_name], :cms => true
        end
      end
      if @validator
        errors = @validator.validate(doc, options)
        errors.each do |error|
          add_warning error.message,
                      :location => error.location,
                      :validator => error.validator,
                      :validator_type => :xml_validation,
                      :file_name => @options[:file_name],
                      :cms => true
        end
      end
    end
  end

  class CMSQRDA3SchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = Cypress::AppConfig['default_bundle'])
      super(File.join(Rails.root, 'resources', 'schematron', schematron_folder_for_bundle_version(bundle_version), 'EP_CAT_III.sch'),
            'CMS QRDA 3 Schematron Validator', bundle_version)
    end
  end

  class CMSQRDA1HQRSchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = Cypress::AppConfig['default_bundle'])
      super(File.join(Rails.root, 'resources', 'schematron', schematron_folder_for_bundle_version(bundle_version), 'EH_CAT_I.sch'),
            'CMS QRDA 1 HQR Schematron Validator', bundle_version)
    end
  end

  class CMSQRDA1PQRSSchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = Cypress::AppConfig['default_bundle'])
      super(File.join(Rails.root, 'resources', 'schematron', schematron_folder_for_bundle_version(bundle_version), 'EP_CAT_I.sch'),
            'CMS QRDA 1 PQRS Schematron Validator', bundle_version)
    end
  end
end
