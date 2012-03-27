require 'measure_evaluator'
require 'patient_zipper'
require 'open-uri'
require 'prawnto'

class ProductTestsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @test = ProductTest.find(params[:id])
    @product = @test.product
    @vendor = @product.vendor
    @patients = Record.where(:test_id => @test.id)

    
    # Decide our current execution. Show the one requested, if any. Otherwise show the most recent, or a new one if none exist
    if !params[:execution_id].nil?
      @current_execution = TestExecution.find(params[:execution_id])
    elsif @test.test_executions.size > 0
      @current_execution = @test.ordered_executions.first
    else
      @never_executed_before = true
      @current_execution = TestExecution.new({:product_test => @test, :execution_date => Time.now})
    end
    
    # Calculate and categorize the passing and failing measures
    passing_measures = @current_execution.passing_measures
    failing_measures = @current_execution.failing_measures
    @measures = { 'fail' => failing_measures, 'pass' => passing_measures }
    
    # Calculate the time remaining
    @loading_progress = {}

    # For the population to be cloned or imported
    
    # population_creation_job
    # And for the measures to be calculated
    @percent_completed = ((@test.measure_defs.size - @test.result_calculation_jobs.size).to_f / @test.measure_defs.size.to_f) * 100
    
    respond_to do |format|
      # Don't send tons of JSON until we have results. In the meantime, just update the client on our calculation status.
      format.json do
        if @percent_completed < 100
          render :json => { 'percent_completed' => @percent_completed }
        else
          render :json => {'test' => @test, 'results' => @current_execution.expected_results, 'percent_completed' => @percent_completed, 'patients' => @patients }
        end
      end
      
      format.html { render :action => "show" }
      
      format.pdf { render :layout => false }
      prawnto :filename => "#{@test.name}.pdf"
    end
  end
  
  def new
    @test = ProductTest.new
    @product = Product.find(params[:product])
    @vendor = @product.vendor
    @measures = Measure.top_level
    @patient_populations = PatientPopulation.installed
    @measures_categories = @measures.group_by { |t| t.category }
    
    # TODO - Copied default from popHealth. This probably needs to change at some point. We also currently ignore the uploaded value anyway.
    @effective_date = Time.gm(2010, 12, 31)
    @period_start = 3.months.ago(Time.at(@effective_date))
  end
  
  def create
    # Create a new test and save here so id is made. We'll use it while cloning Records to associate them back to this ProductTest.
    test = ProductTest.new(params[:product_test])
    month, day, year = params[:product_test][:effective_date_end].split('/')
    test.effective_date = Time.local(year.to_i, month.to_i, day.to_i).to_i
    test.save!
    
    if params[:byod] && Rails.env != 'production'
      # If the user brought their own data, kick off a PatientImportJob. Store the file temporarily in /tmp
      uploaded_file = params[:byod].tempfile
      byod_path = "/tmp/byod_#{test.id}_#{Time.now.to_i}"
      format = params[:product_test][:upload_format]
      File.rename(File.path(uploaded_file), byod_path)
      
      test.population_creation_job = Cypress::PatientImportJob.create(:zip_file_location => byod_path, :test_id => test.id, :format => format)
    elsif params[:patient_ids]
      test.population_creation_job = Cypress::PopulationCloneJob.create(:patient_ids => params[:patient_ids], :test_id => test.id)
    else
      # Otherwise we're making a subset of the Test Deck
      test.population_creation_job = Cypress::PopulationCloneJob.create(:subset_id => params[:product_test][:patient_population], :test_id => test.id)
      test.patient_population = PatientPopulation.where(:name => params[:product_test][:patient_population]).first
    end

    test.download_filename = params[:download_filename]
    test.save!

    redirect_to product_test_path(test)
  end
  
  def edit
    @test = ProductTest.find(params[:id])
    @product = @test.product
    @vendor = @product.vendor
    @effective_date = @test.effective_date
    @period_start = 3.months.ago(Time.at(@effective_date))
  end
  
  def update
    test = ProductTest.find(params[:id])
    test.update_attributes(params[:product_test])
    test.measure_ids.select! {|id| id.size > 0}
    test.save!
   
    redirect_to product_test_path(test)
  end
  
  def destroy

    test = ProductTest.find(params[:id])
    product = test.product
    
    # If a TestExecution was included as a param, just delete that.
    if params[:execution_id]
      TestExecution.find(params[:execution_id]).destroy
    else
      # Otherwise, delete the whole ProductTest and get rid of all the Records, TestExecutions, and patient_cache entries that are associated with it.
       # Get rid of all related Records to this test
        Record.where(:test_id => test.id).each do |record|
          MONGO_DB.collection('patient_cache').remove({'value.patient_id' => record.id})
          record.destroy
        end
        
        # Get rid of all related executions
        test.test_executions.each do |execution|
          execution.destroy
        end

      test.destroy
    end

    redirect_to product_path(product)
  end

  #calculates the period for reporting based on effective date (end date)
  def period
    month, day, year = params[:effective_date].split('/')
    @effective_date = Time.local(year.to_i, month.to_i, day.to_i).to_i
    @period_start = 3.months.ago(Time.at(@effective_date))
    render :period, :status=>200
  end

  # Accept a PQRI document and use it to define a new TestExecution on this ProductTest
  def process_pqri
    test = ProductTest.find(params[:id])
    test_data = params[:product_test]
    baseline = test_data[:baseline]
    pqri = test_data[:pqri]
    
    execution = TestExecution.new({:product_test => test, :execution_date => Time.now.to_i})
    
    doc = Nokogiri::XML(pqri.open)
    execution.reported_results = Cypress::PqriUtility.extract_results(doc)
    execution.validation_errors = Cypress::PqriUtility.validate(doc)
    
    # If a vendor cannot run their measures in a vaccuum (i.e. calculate measures with just the patient test deck) then
    # we will first import their measure results with their own patients so we can establish a baseline in order
    # to normalize with a second PQRI with results that include the test deck.
    if (baseline)
      doc = Nokogiri::XML(baseline.open)
      execution.baseline_results = Cypress::PqriUtility.extract_results(doc)
      execution.baseline_validation_errors = Cypress::PqriUtility.validate(doc)

      execution.normalize_results_with_baseline
    end
    
    execution.save!
    redirect_to :action => 'show'
  end

  # Save and serve up the Records associated with this ProductTest. Filetype is specified by :format
  def download
    test = ProductTest.find(params[:id])
    
    file = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => test.id)
    
    format = params[:format]
    filename = test.download_filename || "#{test.name}_html.zip"
    if params[:format].nil? then
      format = /(ccr|html|csv|c32)\.zip/.match(filename)[1]
    else
      original_format = /((ccr|html|csv|c32)\.zip)/.match(filename)[1]
      filename = filename.sub(original_format,format)
    end

    if format == 'csv'
      Cypress::PatientZipper.flat_file(file, patients)
      send_file file.path, :type => 'text/csv', :disposition => 'attachment', :filename => filename
    else
      Cypress::PatientZipper.zip(file, patients, format.to_sym)
      send_file file.path, :type => 'application/zip', :disposition => 'attachment', :filename => filename
    end
    
    file.close
  end

end
