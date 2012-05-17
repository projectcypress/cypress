require 'measure_evaluator'
require 'create_download_zip'
require 'get_dependencies'
require 'open-uri'
require 'prawnto'

class ProductTestsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @test = ProductTest.find(params[:id])
    @product = @test.product
    @product.measure_map ||= Measure.default_map
    @vendor = @product.vendor
    @patients = Record.where(:test_id => @test.id)

    # Decide our current execution. Show the one requested, if any. Otherwise show the most recent, or a new one if none exist
    if !params[:execution_id].nil?
      @current_execution = TestExecution.find(params[:execution_id])   
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
    @product.measure_map ||= Measure.default_map

    @measures_categories = @measures.select do |t|
      @product.measure_map.keys.include?(t[:id])
    end.group_by {|g| g.category}

    # TODO - Copied default from popHealth. This probably needs to change at some point. We also currently ignore the uploaded value anyway.
    @effective_date = Time.gm(2010, 12, 31)
    @period_start = 3.months.ago(Time.at(@effective_date))
  end
  
  def create
    # Create a new test and save here so id is made. We'll use it while cloning Records to associate them back to this ProductTest.
    test = current_user.product_tests.build(params[:product_test])
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
      if params[:population_description] && !params[:population_name].empty?
        # if the user has created a population using the minimal_set feature
        # and they want to save it for subsequent tests
        population = PatientPopulation.new({:product_test => test, :name => params[:population_name], :description => params[:population_description],
            :patient_ids => params[:patient_ids], :user => User.where({:email => current_user[:email]}).first })
        population.save!
        test.population_creation_job = Cypress::PopulationCloneJob.create(:subset_id => params[:population_name], :test_id => test.id)
        test.patient_population = population
      else
        test.population_creation_job = Cypress::PopulationCloneJob.create(:patient_ids => params[:patient_ids], :test_id => test.id)
      end
    else
      # Otherwise we're making a subset of the Test Deck
      test.population_creation_job = Cypress::PopulationCloneJob.create(:subset_id => params[:product_test][:patient_population], :test_id => test.id)
      test.patient_population = PatientPopulation.where(:name => params[:product_test][:patient_population]).first
    end
    
    test.save!

    redirect_to product_test_path(test)
  end
  
  def edit
    @test = current_user.product_tests.find(params[:id])
    @product = @test.product
    @vendor = @product.vendor
    @effective_date = @test.effective_date
    @period_start = 3.months.ago(Time.at(@effective_date))
  end
  
  def update
    test = current_user.product_tests.find(params[:id])
    test.update_attributes(params[:product_test])
    test.measure_ids.select! {|id| id.size > 0}
    test.save!
   
    redirect_to product_test_path(test)
  end
  
  def destroy
    test = current_user.product_tests.find(params[:id])
    product = test.product
    
    # If a TestExecution was included as a param, just delete that.
    if params[:execution_id]
      TestExecution.find(params[:execution_id]).destroy
    else
      # Otherwise, delete the whole ProductTest and get rid of all the Records, TestExecutions, and patient_cache entries that are associated with it.
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
    test = current_user.product_tests.find(params[:id])
    product = test.product
    test_data = params[:product_test] || {}

    baseline = test_data[:baseline]
    pqri = test_data[:pqri]
    product = test.product
    measure_map = product.measure_map if product

    if !params[:execution_id].empty?
      execution = TestExecution.find(params[:execution_id])
    else
      execution = TestExecution.new({:product_test => test, :execution_date => Time.now, :product_version=>product.version})
    end
    
    # If a vendor cannot run their measures in a vacuum (i.e. calculate measures with just the patient test deck) then
    # we will first import their measure results with their own patients so we can establish a baseline in order
    # to normalize with a second PQRI with results that include the test deck.

    if (baseline)
      doc = Nokogiri::XML(baseline.open)
      execution.baseline_results = Cypress::PqriUtility.extract_results(doc, measure_map)
      execution.baseline_validation_errors = Cypress::PqriUtility.validate(doc)          
    end

    if pqri
      doc = Nokogiri::XML(pqri.open)
      execution.reported_results = Cypress::PqriUtility.extract_results(doc, measure_map)
      execution.validation_errors = Cypress::PqriUtility.validate(doc)
      if execution.baseline_results
        execution.normalize_results_with_baseline
      end      
    end
    execution.execution_date=Time.now.to_i
    execution.product_version=product.version
    execution.required_modules=Cypress::GetDependencies::get_dependencies
    
    execution.save!
    redirect_to :action => 'show', :execution_id=>execution._id
  end

  # Save and serve up the Records associated with this ProductTest. Filetype is specified by :format
  def download
    test = current_user.product_tests.find(params[:id])
    format = params[:format]
    file = Cypress::CreateDownloadZip.create_test_zip(test.id,format)

    if format == 'csv'
      send_file file.path, :type => 'text/csv', :disposition => 'attachment', :filename => "Test_#{test.id}.csv"
    else
      send_file file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "Test_#{test.id}._#{format}.zip"
    end
    
    file.close
  end

  def delete_note
    test = ProductTest.find(params[:id])

    note = test.notes.find(params[:note][:id])
    note.destroy

    redirect_to :action => 'show', :execution_id => params[:execution_id]
  end

  def add_note
    test = ProductTest.find(params[:id])

    note = Note.new(params[:note])
    note.time = Time.now

    test.notes << note
    test.save!

    redirect_to :action => 'show', :execution_id => params[:execution_id]
  end
end
