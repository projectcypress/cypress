module Validators
  class CMSSchematronValidator < QrdaFileValidator
    include Validators::Validator
    include HealthDataStandards::Validate

    def initialize(schematron_file, name)
      @validator = Schematron::Validator.new(name, schematron_file)
    end

    def validate(file, options = {})
      @errors = []
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
end
