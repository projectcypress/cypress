require 'measure_evaluator'

class MeasuresController < ApplicationController
  before_filter :authenticate_user!

  def show
    @test = ProductTest.find(params[:product_test_id])
    if !params[:execution_id].nil?
      @current_execution = TestExecution.find(params[:execution_id])
    elsif @test.test_executions.size > 0
      @execution = @test.test_executions.first
    else
      @execution = TestExecution.new({:product_test => @test, :execution_date => Time.now})
    end
    @product = @test.product
    @vendor = @product.vendor
    
    @measure = Measure.find(params[:id])
    @measures = Measure.top_level
    @measures_categories = @measures.group_by { |t| t.category }
    
    respond_to do |format|
      format.json { render :json => @execution.expected_result(@measure) }
      format.html { render :action => "show" }
    end
  end
  
  def patients
    @test = ProductTest.find(params[:product_test_id])
    if !params[:execution_id].nil?
      @current_execution = TestExecution.find(params[:execution_id])
    elsif @test.test_executions.size > 0
      @execution = @test.test_executions.first
    else
      @execution = TestExecution.new({:product_test => @test, :execution_date => Time.now})
    end
    @product = @test.product
    @vendor = @product.vendor
    @measure = Measure.find(params[:id])
    @result = @execution.expected_result(@measure)
    
    @patients = Result.where("value.test_id" => @test.id).where("value.measure_id" => @measure['id'])
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
