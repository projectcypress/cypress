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
  def minimal_set
    measure_ids = params[:measure_ids]
    num_records = [params[:num_records].to_i, 5].max


    @coverage = {}
    #all_patients = []  if you don't want the minimal set, uncomment this
    minimal_set = PatientPopulation.min_coverage(measure_ids)
    all_patients = minimal_set[:minimal_set]
    overflow_patients = minimal_set[:overflow]
    all_measures = []
    
    # stub code for the queries that determine the appropriate set of patients
    Measure.installed.each do |measure|
      if measure_ids.any? {|m| m == measure[:id]}
        Result.where('value.test_id' => nil).where('value.measure_id' => measure['id']).where('value.population' => true).each do |result|
          key = measure.key
          @coverage[key] = {:name => measure[:name] + ( measure[:subtitle] ? ': ' + measure[:subtitle] : ''), :num => 0, :den => 0, :exc => 0, :ant => 0, :patients => []} unless @coverage[key]
          #if you don't want the minimal set, uncomment the following 2 lines
          #@coverage[key][:patient_ids].push(result.value.patient_id)
          #all_patients.push(result.value.patient_id)
          all_measures.push(measure)
        end
      end
    end

    # collect the patient records
    #unique_patients = all_patients.uniq.slice(0, num_records)
    unique_patients = all_patients
    #if you don't want the minimal set, uncomment the following line
    #@patient_list = Record.where( { _id: { "$in" => unique_patients } } ).order_by([["_id", :desc]]);
    @patient_list = Record.where( { _id: { "$in" => all_patients } } ).order_by([["_id", :desc]])
    @overflow = Record.where({ _id: { "$in" => overflow_patients } })

    # loop through and tally the num/den/exc
    all_measures.uniq.each do |measure|
      Result.where('value.test_id' => nil).where('value.measure_id' => measure['id']).where('value.population' => true).each do |result|
        if unique_patients.any? {|id| id == result['value']['patient_id'] }
          key = measure.key
          patient = Record.find(result['value']['patient_id'])
          if !@coverage[key][:patients].include?(patient)
            @coverage[key][:num] += 1 if result['value']['numerator']
            @coverage[key][:den] += 1 if result['value']['denominator']
            @coverage[key][:ant] += 1 if result['value']['antinumerator']
            @coverage[key][:exc] += 1 if result['value']['exclusions']
            @coverage[key][:patients].push(patient)
          end
        end
      end
    end
    
    # end stub
    respond_to do |format|
      format.js { render :layout => false }
      format.json {render :json => {:coverage => @coverage}}      
    end
  end

end
