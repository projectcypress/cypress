module Validators
  class CMSSchematronValidator < QrdaFileValidator
    include Validators::Validator
    include HealthDataStandards::Validate

    def initialize(schematron_file, name)
      @validator = Schematron::Validator.new(name, schematron_file)
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
    def initialize
      super(File.join(Rails.root, 'resources', 'schematron', 'EP CMS 2016 QRDA Category III v3.sch'),
            'CMS QRDA 3 Schematron Validator')
    end
  end

  class CMSQRDA1HQRSchematronValidator < CMSSchematronValidator
    def initialize
      super(File.join(Rails.root, 'resources', 'schematron', 'HQR CMS 2016 QRDA Category I v3.sch'),
            'CMS QRDA 1 HQR Schematron Validator')
    end
  end

  class CMSQRDA1PQRSSchematronValidator < CMSSchematronValidator
    def initialize
      super(File.join(Rails.root, 'resources', 'schematron', 'PQRS CMS 2016 QRDA Category I v3.sch'),
            'CMS QRDA 1 PQRS Schematron Validator')
    end
  end
end
