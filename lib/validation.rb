module Validation

  C32_V2_1_2_3_TYPE = 'C32 v2.1/v2.3'
  C32_V2_5_TYPE     = 'C32 v2.5'
  C32_NHIN_TYPE     = 'NHIN C32'
  CCR_TYPE          = 'CCR'

   def Validation.unregister_validators
     ValidationRegistry.instance.unregister_validators
   end
   
   def Validation.register_validator(doc_type, validator)
     ValidationRegistry.instance.register_validator(doc_type, validator)
   end
   
   def Validation.get_validator(type)
     ValidationRegistry.instance.get_validator(type)
   end
   
   def Validation.validate(patient_data, document)
     get_validator(document.doc_type).validate(patient_data,document)
   end

   def Validation.types
     ValidationRegistry.instance.types
   end

   class InvalidValidatorException < Exception
   end
   
   # this is just a stubbed out marker class to we can ensure that
   # everything that is registered as a validator really is one
   class BaseValidator
     include Logging
     attr_accessor :validation_type

     def validate(patient_data, document)
         raise "Implement me damn it"
     end
     
   end
 
  # This base class is used as a clue to the Validator to let it know
  # that it should supply the path to the file rather than an in memory
  # document tree of the xml.
  class FileValidator < BaseValidator; end
 
  class Validator
   
    attr_accessor :validators
    @validators = []
    @doc_type
    
    def initialize(doc_type)
      @validators = []
      @doc_type= doc_type
    end
    
    def validate(patient_data, document, options = {})
      logger = options[:logger]
      errors = []
      # see if we have been given a ClinicalDocument, if so, get the xml
      xml_document = document.respond_to?(:as_xml_document) ? document.as_xml_document : document
      # and get the public path to the file if available
      xml_file_path = document.public_filename if document.respond_to?(:public_filename)
      validators.each do |validator|
        validator.logger = logger if logger
        case validator
          when FileValidator
            errors.concat(validator.validate(patient_data, xml_file_path))
          else
            errors.concat(validator.validate(patient_data, xml_document))
        end
      end

      errors
    end
    
    def << (validator)

         raise InvalidValidatorException if !validator.kind_of? Validation::BaseValidator
         validators << validator
    end
    
    def contains?(validator)
      validators.include?(validator)
    end
    
    def contains_kind_of?(validator)
      validators.any? {|v| v.kind_of?(validator)}
    end
  end 
  
  class ValidationRegistry
    include Singleton
    attr_reader :validators, :types

    def initialize()
       @validators={}
       @types = Set.new
    end

    def unregister_validators
      initialize
    end

    def register_validator(doc_type, validator)
      @types << doc_type
      
      raise InvalidValidatorException if !validator.kind_of? Validation::BaseValidator
     
      validator.validation_type = doc_type.to_s if validator.validation_type.nil? 
      doc_validator = get_validator(doc_type)
      doc_validator << validator unless doc_validator.contains?(validator)
    end

    def get_validator(type)
      # just to make sure everything is normalized to capitalized symbols
      doc_type = type.class == Symbol ? type.to_s.upcase.to_sym : type.upcase.to_sym
      validator = @validators[doc_type]
      unless validator
        validator = Validator.new(type)
        @validators[doc_type] = validator
      end
      validator
    end

  end
end
