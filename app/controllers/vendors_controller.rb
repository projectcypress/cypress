require 'measure_evaluator'
require 'patient_zipper'

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
  end
  
  def create
    vendor = Vendor.new(params[:vendor])
    vendor.effective_date = Time.local(2011,3,31).to_i
    vendor.measure_ids.select! {|id| id.size>0}
    vendor.save! # save here so _id is created
    
    # Generate random records for this test run
    #vendor.patient_gen_job = QME::Randomizer::PatientRandomizationJob.create(
    #  :template_dir => Rails.root.join('db', 'templates').to_s,
    #  :count => 100,
    #  :test_id => vendor._id)
    
    # Clone AMA records from Mongo
    ama_patients = Record.where(:test_id => nil)
    ama_patients.each do |patient|
      cloned_patient = patient.clone
      cloned_patient.test_id = vendor._id
      cloned_patient.save!
    end
    
    vendor.save!
    
    redirect_to :action => 'show', :id => vendor.id
  end
  
  def show
    @vendor = Vendor.find(params[:id])

    respond_to do |format|
      format.json { render :json => {'vendor' => @vendor, 'results'=>@vendor.expected_results }}
      format.html { render :action => "show" }
    end
  end
  
  def edit
    @vendor = Vendor.find(params[:id])
    @measures = Measure.top_level
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
  
  def upload_pqri
    @vendor = Vendor.find(params[:id])
  end
  
  def process_pqri
    vendor = Vendor.find(params[:id])
    vendor_data = params[:vendor]
    pqri = vendor_data[:pqri]
    doc = Nokogiri::XML(pqri.open)
    vendor.extract_reported_from_pqri(doc)
    vendor.save!
    redirect_to :action => 'show'
  end

  def zipc32
    vendor = Vendor.find(params[:id])
    t = Tempfile.new("patients-#{Time.now}")
    patients = Record.where("test_id" => vendor.id)
    Cypress::PatientZipper.zip(t, patients, :c32)
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', 
      :filename => 'patients_c32.zip'
    t.close
  end

  def zipccr
    vendor = Vendor.find(params[:id])
    t = Tempfile.new("patients-#{Time.now}")
    patients = Record.where("test_id" => vendor.id)
    Cypress::PatientZipper.zip(t, patients, :ccr)
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', 
      :filename => 'patients_ccr.zip'
    t.close
  end

end
