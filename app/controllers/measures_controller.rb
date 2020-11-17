class MeasuresController < ApplicationController
  include API::Controller

  def index
    @measures = Bundle.find(params[:bundle_id]).measures
    respond_with(@measures.to_a)
  end
end
