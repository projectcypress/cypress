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
    test = Run.new(:effective_date=>Time.gm(2010,12,31).to_i)
    test.measure_ids = ['0001', '0002', '0013']
    vendor.tests << test
    vendor.save! # save here so _id is created
    test_run = vendor.tests.last
    
    # Generate random records for this test run
    test_run.patient_gen_job = QME::Randomizer::PatientRandomizationJob.create(
      :template_dir => Rails.root.join('db', 'templates').to_s,
      :count => 100,
      :test_id => test_run._id)
    vendor.save!
    
    redirect_to :action => 'index'
  end
  
  def show
    @vendor = Vendor.find(params[:id])
    @test = @vendor.tests.last
    @measures = measure_defs(@test.measure_ids)
    @results = measure_results(@measures, @test)
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
  
  def measure_results(measures, test)
    measures.collect do |measure|
      patient_gen_status = Resque::Status.get(test.patient_gen_job)
      report = QME::QualityReport.new(measure['id'], measure.sub_id, 
        {'effective_date'=>test.effective_date, 'test_id'=>test.id})
      result = {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?'}
      if report.calculated?
        result = report.result
      elsif patient_gen_status.completed?
        report.calculate
      end
      result
    end
  end
  
  def measure_defs(measure_ids)
    measure_ids.collect do |measure_id|
      Measure.where(id: measure_id).order_by([[:sub_id, :asc]]).all()
    end.flatten
  end
    
end
