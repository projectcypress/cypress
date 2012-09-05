module Validators
  module Schema
    class Validator < Validation::BaseValidator
      
      attr_accessor :validator_name
      
      def initialize(name, schema_file)
        @validator_name = name
        @schema_file = schema_file
        @xsd = Nokogiri::XML::Schema(File.read(@schema_file))
      end
      
      # Validate the document against the configured schema
      def validate(document)
          errors = []
          @xsd.validate(document).each do |error|
             errors << Cypress::ValidationError.new(
                :message => error.message,
                :validator => @validator_name,
                :inspection_type=>::XML_VALIDATION_INSPECTION
              )
            puts error.message
          end
       errors
      end
    end
  end
end
  
