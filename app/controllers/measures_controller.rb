
class MeasuresController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_test_and_execution, only: [:show, :patients]
  before_filter :find_measure, only: [:show,:patients]
  before_filter :find_product, only: [:show,:patients,:minimal_set]

  def by_type
    @measures = Measure.top_level
    #uncomment this when we have measures of different types
    #    @measures = Measure.where(type: params[:type])
    @measures_categories = @measures.group_by { |t| t.category }
    respond_to do |format|
      format.js { render :layout => false }
      format.json {render :json => {:measures => @measures, :measures_categories => @measures_categories}}
    end

  end
  
  
  def show
    
    @vendor = @product.vendor  
    @measures = @test.measures
    @measures_categories = @measures.group_by { |t| t.category }
    @product.measure_map ||= Measure.default_map

    respond_to do |format|
      format.json { render :json => @execution.expected_results }
      format.html { render :action => "show" }
    end
  end
  
  def definition
    render :json => Measure.find(params[:measure_id])
  end
  
  def patients
   
    @vendor = @product.vendor
    @result = @execution.expected_result(@measure)
    
    @patients = Result.where("value.test_id" => @test.id).where("value.measure_id" => @measure['id'])
    .where("value.sub_id" => @measure.sub_id)

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
    @patient_list = Record.where( { _id: { "$in" => minimal_ids } } ).only(:_id, :first, :last, :birthdate, :gender, :patient_id).order_by([["_id", :desc]]).to_a
    @overflow = Record.where({ _id: { "$in" => overflow_ids } }).only(:_id, :first, :last, :birthdate, :gender, :patient_id).to_a
    
    # Get the results that are relevant to the measures and patients the user asked for
    results = Result.where({'value.measure_id' => { "$in" => measure_ids}, 'value.patient_id' => { "$in" => minimal_ids | overflow_ids } })
    
    # Use the relevant results to build @coverage of each measure
    @coverage = {}
    buckets = ["denominator", "numerator", "exclusions", "antinumerator"]
    results.each do |result|
      # Skip results that don't fall into any of the buckets
      next if !result.value['numerator'] && !result.value['denominator'] && !result.value['antinumerator'] && !result.value['exclusions']
      
      # Identify the measure to which this result is referring
      measure = "#{result.value.measure_id}#{result.value.sub_id}".to_s

      # Add this measure to the patients for easy lookup in both directions (i.e. patients <-> measures)
      patient_index = @patient_list.index{|patient| patient.id == result.value.patient_id}
      if patient_index
        patient = @patient_list[patient_index]
      else
        patient_index = @overflow.index{|patient| patient.id == result.value.patient_id}
        patient = @overflow[patient_index]
      end
      patient['measures'] ||= []
      patient['measures'] << measure
      
      # Add the patient along with their placement in buckets to this measure
      @coverage[measure] ||= {}
      @coverage[measure][patient._id] = {}
      buckets.each do |bucket|
        bucket_value = result.value[bucket] ? 1 : 0
        @coverage[measure][patient._id][bucket] = bucket_value
      end
    end
    
    respond_to do |format|
      format.js { render :layout => false }
      format.json {render :json => {:coverage => @coverage}}      
    end
  end
  
  
  private
  
  def find_product
    if @test.nil?
      @product = Product.find(params[:id]) if params[:id]
      @product = Product.find(params[:product_id]) if params[:product_id]
    else
      @product = @test.product
    end
    
  end
  
  def find_measure
    @measure = Measure.find(params[:id])
  end
  
  
  def find_test_and_execution
    @test = ProductTest.find(params[:product_test_id])
    if params[:execution_id]
      @current_execution = TestExecution.find(params[:execution_id])
    elsif @test.test_executions.size > 0
      @execution = @test.test_executions.first
    else
      @execution = TestExecution.new({:product_test => @test, :execution_date => Time.now})
    end
  end
  
  
  


end
