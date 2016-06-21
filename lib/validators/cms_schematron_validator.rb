module Validators
  class CMSSchematronValidator < QrdaFileValidator
    include Validators::Validator
    include HealthDataStandards::Validate

    self.validator = :cms_schematron

    def initialize(schematron_file, name)
      @validator = Schematron::Validator.new(name, schematron_file)
    end

    def schematron_folder_for_bundle_version(bundle_version)
      ApplicationController.helpers.config_for_version(bundle_version).schematron
    end

    def validate(file, options = {})
      @options = options
      doc = get_document(file)
      errors = @validator.validate(doc, options)
      errors.each do |error|
        add_warning error.message,
                    :location => error.location,
                    :validator => error.validator,
                    :validator_type => :xml_validation,
                    :file_name => @options[:file_name]
      end
    end
  end

  class CMSQRDA3SchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = APP_CONFIG.default_bundle)
      super(File.join(Rails.root, 'resources', 'schematron', schematron_folder_for_bundle_version(bundle_version) ,'EP_CAT_III.sch'),
            'CMS QRDA 3 Schematron Validator')
    end
  end

  class CMSQRDA1HQRSchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = APP_CONFIG.default_bundle)
      super(File.join(Rails.root, 'resources', 'schematron', schematron_folder_for_bundle_version(bundle_version) ,'EH_CAT_I.sch'),
            'CMS QRDA 1 HQR Schematron Validator')
    end
  end

  class CMSQRDA1PQRSSchematronValidator < CMSSchematronValidator
    def initialize(bundle_version = APP_CONFIG.default_bundle)
      
      super(File.join(Rails.root, 'resources', 'schematron', schematron_folder_for_bundle_version(bundle_version) ,'EP_CAT_I.sch'),
            'CMS QRDA 1 PQRS Schematron Validator')
    end
  end

  
end
