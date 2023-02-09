# frozen_string_literal: true

class MeasuresController < ApplicationController
  include API::Controller

  def index
    @measures = Bundle.find(params[:bundle_id]).measures
    respond_with(@measures.to_a)
  end

  def grouped
    @bundle = Bundle.find(params[:bundle_id])
    @measures = @bundle.measures.only(:cms_id, :description, :title, :category, :hqmf_id, :reporting_program_type)
    @measures_categories = @measures.group_by(&:category)
    render partial: 'products/measure_selection', locals: { measures_categories: @measures_categories }
  end

  def filtered
    # Only allow word characters and whitespace characters in the filter
    @filter = Regexp.escape(params[:filter]) if params[:filter]
    @bundle = Bundle.find(params[:bundle_id])
    @measures = @bundle.measures.and(
      Measure.any_of({ title: /#{@filter}/i }, cms_id: /#{@filter}/i).selector
    ).only(:hqmf_id, :category, :reporting_program_type)
    @measures_categories = @measures.group_by(&:category)
    render partial: 'products/measure_selection', formats: :json, handlers: :jbuilder
  end
end
