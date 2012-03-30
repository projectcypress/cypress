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
    if params[:product_test_id]
      @measures = @test.measure_defs
    else
      @measures = Measure.top_level
    end

    @measures_categories = @measures.group_by { |t| t.category }
    
    if params[:measure_id]
      @selected = Measure.find(params[:measure_id])
    else
      @selected = @measures[0]
    end
    
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

  

  # Find the minimal set of patient records required to cover the list of measures passed in
  #
  # @patient_list - The minimal set
  # @overflow - All other patients relevant to the measures passed in
  # @coverage - Maps measures to the list of associated patients in both @patient_list and @overflow
  def minimal_set
    measure_ids = params[:measure_ids]

    # Find the IDs of all Records for our minimal set and overflow
    minimal_set = PatientPopulation.min_coverage(measure_ids)
    minimal_ids = minimal_set[:minimal_set]
    overflow_ids = minimal_set[:overflow]
    
    # Query to find the actual Records for our minmal set and overflow
    @patient_list = Record.where( { _id: { "$in" => minimal_ids } } ).only(:_id, :first, :last, :birthdate, :gender).order_by([["_id", :desc]])
    @overflow = Record.where({ _id: { "$in" => overflow_ids } }).only(:_id, :first, :last, :birthdate, :gender)
    all_patients = @patient_list | @overflow
    
    # Get the results that are relevant to the measures and patients the user asked for
    results = Result.where({'value.measure_id' => { "$in" => measure_ids}, 'value.patient_id' => { "$in" => minimal_ids | overflow_ids } })
    
    # Use the relevant results to build @coverage of each measure
    @coverage = {}
    buckets = ['numerator', 'denominator', 'antinumerator', 'exclusion']
    results.each do |result|
      # Increment each bucket for the measure if this result belongs
      measure = "#{result.value.measure_id}#{result.value.sub_id}".to_s
      @coverage[measure] ||= {}
      buckets.each do |bucket|
        @coverage[measure][bucket] ||= 0
        @coverage[measure][bucket] += 1 if result.value[bucket]
      end
      # Find and add this results' patient to the list if we haven't done so already. We use just a condensed version of the patient
      index = all_patients.index{|patient| patient.id == result.value.patient_id}
      patient = all_patients[index]
      @coverage[measure]['patients'] ||= []
      @coverage[measure]['patients'] << patient if !@coverage[measure]['patients'].include?(patient)
    end
    
    respond_to do |format|
      format.js { render :layout => false }
      format.json {render :json => {:coverage => @coverage}}      
    end
  end

end
