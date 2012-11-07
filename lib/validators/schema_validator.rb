module Validators
  module Schema
    class Validator 
      
      attr_accessor :validator_name
      
      def initialize(name, schema_file)
        @validator_name = name
        @schema_file = schema_file
        @xsd = Nokogiri::XML::Schema(File.new(@schema_file))
      end
      
      # Validate the document against the configured schema
      def validate(document,data={})
          errors = []
          doc = (document.kind_of? Nokogiri::XML::Document)? document : Nokogiri::XML(document.to_s)
          @xsd.validate(doc).each do |error|
             errors << Cypress::ValidationError.new(
                :message => error.message,
                :validator => @validator_name,
                :validator_type => :xml_validation,
                :msg_type=>(data[:msg_type] || :error),
                :file_name => data[:file_name],
                location: "/"
              )
            
          end
       errors
      end
    end
  end
end
  
