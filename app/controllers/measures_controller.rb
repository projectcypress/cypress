class MeasuresController < ApplicationController
  include API::Controller

  def index
    @measures = Bundle.find(params[:bundle_id]).measures.top_level
    respond_with(@measures.to_a)
  end

  def grouped
    @bundle = Bundle.find(params[:bundle_id])
    @measures = @bundle.measures.top_level.only(:cms_id, :sub_id, :name, :category, :hqmf_id, :type)
    @measures_categories = @measures.group_by(&:category)
    render partial: 'products/measure_selection'
  end

  def filtered
    # Only allow word characters and whitespace characters in the filter
    @filter = Regexp.escape(params[:filter]) if params[:filter]
    @bundle = Bundle.find(params[:bundle_id])
    @measures = @bundle.measures.top_level.and(
      Measure.any_of({ name: /#{@filter}/i }, cms_id: /#{@filter}/i).selector
    ).only(:hqmf_id, :category, :type)
    @measures_categories = @measures.group_by(&:category)
    render partial: 'products/measure_selection.json'
  end
end
