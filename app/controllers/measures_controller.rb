class MeasuresController < ApplicationController
  respond_to :json, :xml

  def index
    @measures = Bundle.find(params[:bundle_id]).measures
    respond_with(@measures)
  end

  def grouped
    @bundle = Bundle.find(params[:bundle_id])
    @measures = @bundle.measures.top_level.only(:cms_id, :sub_id, :name, :category, :hqmf_id, :type)
    @measures_categories = @measures.group_by(&:category)
    render partial: 'products/measure_selection'
  end
end
