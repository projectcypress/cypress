require 'measure_evaluator'

class MeasuresController < ApplicationController
  before_filter :authenticate_user!

  def show
    @vendor = Vendor.find(params[:vendor_id])
    @measure = Measure.find(params[:id])
    @measures = Measure.top_level
    @measures_categories = @measures.group_by { |t| t.category }
    
    respond_to do |format|
      format.json { render :json => @vendor.expected_result(@measure) }
      format.html { render :action => "show" }
    end
  end
  
  def patients
    @vendor = Vendor.find(params[:vendor_id])
    @measure = Measure.find(params[:id])
    @result = @vendor.expected_result(@measure)
    @patients = Result.where("value.test_id" => @vendor.id).where("value.measure_id" => @measure['id'])
      .where("value.sub_id" => @measure.sub_id)
    if params[:search] && params[:search].size>0
      @search_term = params[:search]
      regex = Regexp.new('^'+params[:search], Regexp::IGNORECASE)
      patient_ids = Record.any_of({"first" => regex}, {"last" => regex}).collect {|p| p.id}
      @patients = @patients.any_in("value.patient_id" => patient_ids)
    end
    @patients = @patients.order_by([["value.numerator", :desc],["value.denominator", :desc],["value.exclusions", :desc]])
  end
  
end
