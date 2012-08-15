require 'measure_evaluator'
require 'create_download_zip'
require 'get_dependencies'
require 'open-uri'
require 'prawnto'

class ProductTestsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @test = ProductTest.find(params[:id])
  end
  
  def new
    @test = ProductTest.new
    @product = Product.find(params[:product])
    @vendor = @product.vendor
    @effective_date = Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE
    @period_start = 3.months.ago(Time.at(@effective_date)).getgm
  end
  
  def create
    test = test_type.new(params[:product_test])
    test.save!
    redirect_to :action => 'show', :id => test.id, :default_format => default_format
  end
  
  def edit
    @test = current_user.product_tests.find(params[:id])
  end
  
  def update
    test = current_user.product_tests.find(params[:id])
    test.update_attributes(params[:product_test])
    test.save!
    redirect_to product_test_path(test)
  end
  
  def destroy
    test = current_user.product_tests.find(params[:id])
    test.destroy
    redirect_to product_path(product)
  end

  # Send an e-mail to the Vendor POC with an attachment that contains all of the Records included in this test
  def email
    test = ProductTest.find(params[:id])
    format = params[:format]
    
    UserMailer.send_records(test, format).deliver
    
    redirect_to :action => 'show'
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

  
private

  def test_type
    params[:type].constintize
  end

  #calculates the period for reporting based on effective date (end date)
  def period
    month, day, year = params[:effective_date].split('/')
    @effective_date = Time.gm(year.to_i, month.to_i, day.to_i)
    @period_start = 3.months.ago(Time.at(@effective_date)).getgm
    
    render :period, :status => 200
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

    if baseline
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
    execution.required_modules=Cypress::GetDependencies::get_dependencies(Measure.installed.first.bundle)
    
    execution.save!
    redirect_to :action => 'show', :execution_id=>execution._id
  end

 
 
  

end
