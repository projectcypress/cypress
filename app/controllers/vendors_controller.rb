require 'measure_evaluator'
require 'patient_zipper'
require 'open-uri'
require 'prawnto'

class VendorsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @incomplete_vendors = []
    @complete_vendors = []
    vendors = Vendor.all
    vendors.each do |vendor|
      if vendor.passing?
        @complete_vendors << vendor
      else
        @incomplete_vendors << vendor
      end
    end
  end
  
  def new
    @vendor = Vendor.new
    @measures = Measure.top_level
    @measures_categories = @measures.group_by { |t| t.category }
  end
  
  def create
    # We can't save this file with the vendor model so save it so we can pull it out
    uploaded_file = params[:vendor][:byod].tempfile unless !params[:vendor][:byod]
    params[:vendor].delete('byod')
    
    # Create a new vendor and save here so _id is made
    vendor = Vendor.new(params[:vendor])
    vendor.effective_date = Time.local(2011,3,31).to_i   
    vendor.save!
    
    if uploaded_file
      # If the user brought their own data, tell PIJ where to find the uploaded file
      byod_path = "/tmp/byod_#{vendor.id}_#{Time.now.to_i}"
      File.rename(File.path(uploaded_file), byod_path)
      Cypress::PatientImportJob.create(:zip_file_location => byod_path, :test_id => vendor._id)
    else
      # Otherwise we're making a subset of the Test Deck
      Cypress::TDSubsetJob.create(:subset_id => params[:vendor][:patient_population_id], :test_id => vendor._id)  
    end
    
    redirect_to :action => 'show', :id => vendor.id
  end
  
  def show
    @vendor = Vendor.find(params[:id])
    @patients = Record.where(:test_id => @vendor.id)
   
    respond_to do |format|
      format.json { render :json => { 'vendor' => @vendor, 'results'=>@vendor.expected_results, 'patients'=>@patients } }
      format.html { render :action => "show" }
      format.pdf  { render :layout => false }
    end
  end
  
  def edit
    @vendor = Vendor.find(params[:id])
    @measures = Measure.top_level
    @measures_categories = @measures.group_by { |t| t.category }
  end
  
  def destroy
    vendor = Vendor.find(params[:id])
    Record.where(:test_id => vendor._id).delete
    vendor.destroy
    redirect_to :action => :index
  end
  
  def update
    @vendor = Vendor.find(params[:id])
    @vendor.update_attributes(params[:vendor])
    @vendor.measure_ids.select! {|id| id.size>0}
    @vendor.save!
   
    redirect_to :action => 'show'
  end
  
  def delete_note
    @vendor = Vendor.find(params[:id])
    note = @vendor.notes.find(params[:note][:id])
    note.destroy
    redirect_to :action => 'show'
  end
  
  def add_note
    @vendor = Vendor.find(params[:id])
    note = Note.new(params[:note])
    note.time = Time.now
    @vendor.notes << note
    @vendor.save!
    redirect_to :action => 'show'
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
