class ServicesController < ApplicationController
  def index
    @validation_errors = flash[:validation_errors]
    @successful_parse = flash[:successful_parse]
  end
  
  def validate_pqri
    pqri = params[:pqri]
    validation_errors = []
    doc = Nokogiri::XML(pqri.open)
    schema = Nokogiri::XML::Schema(open("http://edw.northwestern.edu/xmlvalidator/xml/Registry_Payment.xsd"))    
    
    schema.validate(doc).each do |error|
      validation_errors << error.message
    end
    
    flash[:validation_errors] = validation_errors
    flash[:successful_parse] = true if !validation_errors.length == 0
    
    redirect_to :action => :index
  end
end