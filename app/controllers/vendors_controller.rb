require 'measure_evaluator'

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
  end
  
  def create
    vendor = Vendor.new(params[:vendor])
    vendor.effective_date = Time.gm(2010,12,31).to_i
    vendor.measure_ids = ['0001', '0002', '0013']
    vendor.save! # save here so _id is created
    
    # Generate random records for this test run
    vendor.patient_gen_job = QME::Randomizer::PatientRandomizationJob.create(
      :template_dir => Rails.root.join('db', 'templates').to_s,
      :count => 100,
      :test_id => vendor._id)
    vendor.save!
    
    redirect_to :action => 'index'
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
  end
  
  def update
    @vendor = Vendor.find(params[:id])
    @vendor.update_attributes!(params[:vendor])
    render :action => 'show'
  end
  
end
