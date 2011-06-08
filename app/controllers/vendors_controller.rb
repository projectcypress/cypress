class VendorsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @incomplete_vendors = Vendor.all(:conditions => {'passed'=>{'$in'=>[nil,false]}})
    @complete_vendors = Vendor.all(:conditions => {'passed'=>true})
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
    @measures = measure_defs(@vendor.measure_ids)
    @results = measure_results(@measures, @vendor)

    respond_to do |format|
      format.json { render :json => {'vendor' => @vendor, 'results'=>@results }}
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
  
  private
  
  def measure_results(measures, vendor)
    patient_gen_status = Resque::Status.get(vendor.patient_gen_job)
    measures.collect do |measure|
      report = QME::QualityReport.new(measure['id'], measure.sub_id, 
        {'effective_date'=>vendor.effective_date, 'test_id'=>vendor.id})
      result = {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?'}
      if report.calculated?
        result = report.result
      elsif patient_gen_status.completed?
        report.calculate
      end
      result['measure_id'] = measure.id.to_s
      result
    end
  end
  
  def measure_defs(measure_ids)
    measure_ids.collect do |measure_id|
      Measure.where(id: measure_id).order_by([[:sub_id, :asc]]).all()
    end.flatten
  end
    
end
