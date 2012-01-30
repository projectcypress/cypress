require 'measure_evaluator'
require 'patient_zipper'
require 'open-uri'
require 'prawnto'

class ProductTestsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @test = ProductTest.find(params[:id])
    @executions = @test.test_executions
    @product = Product.find(params[:product_id])
    @vendor = Vendor.find(params[:vendor_id])
    @incomplete_tests = @product.failing_tests
    @complete_tests = @product.passing_tests
  end
  
  def new
    @test = ProductTest.new
    @product = Product.find(params[:product_id])
    @vendor = Vendor.find(params[:vendor_id])
    @measures = Measure.top_level
    @measures_categories = @measures.group_by { |t| t.category }
    
    # TODO - Copied default from popHealth. This probably needs to change at some point
    @effective_date = Time.gm(2010, 12, 31)
    @period_start = 3.months.ago(Time.at(@effective_date))
  end
  
  def create
    # We can't save this file with the Test model so save it so we can pull it out
    uploaded_file = params[:product_test][:byod].tempfile unless !params[:product_test][:byod]
    params[:product_test].delete('byod')
    
    # Create a new vendor and save here so _id is made
    test = ProductTest.new(params[:product_test])
    test.product_id = params[:product_id]
    test.patient_population = params[:product_test][:patient_population]
    test.save!
    
    if uploaded_file
      # If the user brought their own data, tell PIJ where to find the uploaded file
      byod_path = "/tmp/byod_#{vendor.id}_#{Time.now.to_i}"
      File.rename(File.path(uploaded_file), byod_path)
      Cypress::PatientImportJob.create(:zip_file_location => byod_path, :test_id => test.id)
    else
      # Otherwise we're making a subset of the Test Deck
      Cypress::PopulationCloneJob.create(:subset_id => params[:product_test][:patient_population], :test_id => test.id)  
    end
    
    vendor = Vendor.find(params[:vendor_id])
    product = Product.find(params[:product_id])
    
    redirect_to vendor_product_product_test_path()
  end
  
  def edit
    
  end
  
  def update
    @vendor = Vendor.find(params[:id])
    @vendor.update_attributes(params[:vendor])
    @vendor.measure_ids.select! {|id| id.size>0}
    @vendor.save!
   
    redirect_to :action => 'show'
  end
  
  def destroy
    
  end
  
  def execution
    @test = ProductTest.find(params[:id])
    @execution = @test.test_executions.first
    @patients = Record.where(:test_id => @test.id)
    @product = @test.product
    @vendor = @product.vendor
   
    respond_to do |format|
      format.json { render :json => { 'vendor' => @vendor, 'results'=>@vendor.expected_results, 'patients'=>@patients } }
      format.html { render :action => "show" }
      format.pdf  { render :layout => false }
    end
  end
  
  def process_pqri
    vendor = Vendor.find(params[:id])
    vendor_data = params[:vendor]
    baseline = vendor_data[:baseline]
    pqri = vendor_data[:pqri]
    
    doc = Nokogiri::XML(pqri.open)
    schema = Nokogiri::XML::Schema(open("http://edw.northwestern.edu/xmlvalidator/xml/Registry_Payment.xsd"))
    vendor.reported_results = vendor.extract_results_from_pqri(doc)
    vendor.validation_errors = vendor.validate_pqri(doc, schema)
    
    # If a vendor cannot run their measures in a vaccuum (i.e. calculate measures with just the patient test deck) then
    # we will first import their measure results with their own patients so we can establish a baseline in order
    # to normalize with a second PQRI with results that include the test deck.
    if (baseline)
      doc = Nokogiri::XML(baseline.open)
      schema = Nokogiri::XML::Schema(open("http://edw.northwestern.edu/xmlvalidator/xml/Registry_Payment.xsd"))
      vendor.baseline_results = vendor.extract_results_from_pqri(doc)
      vendor.baseline_validation_errors = vendor.validate_pqri(doc, schema)

      vendor.normalize_results_with_baseline
    end
    
    vendor.save!
    redirect_to :action => 'show'
  end

  def zipc32
    vendor = Vendor.find(params[:id])
    t = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => vendor.id)
    Cypress::PatientZipper.zip(t, patients, :c32)
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', 
      :filename => 'patients_c32.zip'
    t.close
  end
  
  def ziphtml
    vendor = Vendor.find(params[:id])
    t = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => vendor.id)
    Cypress::PatientZipper.zip(t, patients, :html)
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', 
      :filename => 'patients_html.zip'
    t.close
  end
  
  def csv
    vendor = Vendor.find(params[:id])
     t = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => vendor.id)
    Cypress::PatientZipper.flat_file(t, patients)
    send_file t.path, :type => 'text/csv', :disposition => 'attachment', 
      :filename => 'patients_csv.csv'
    t.close
  end

  def zipccr
    vendor = Vendor.find(params[:id])
    t = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => vendor.id)
    Cypress::PatientZipper.zip(t, patients, :ccr)
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', 
      :filename => 'patients_ccr.zip'
    t.close
    
  end
end