class ServicesController < ApplicationController
  def validate_pqri
    if params[:pqri]
      pqri = Nokogiri::XML(params[:pqri].open)
      @validation_errors = Cypress::PqriUtility.validate(pqri)
    end
    
    render :index
  end
end