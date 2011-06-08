class MeasuresController < ApplicationController
  before_filter :authenticate_user!

  def show
    @vendor = Vendor.find(params[:vendor_id])
    @measure = Measure.find(params[:id])
    patient_gen_status = Resque::Status.get(@vendor.patient_gen_job)
    report = QME::QualityReport.new(@measure['id'], @measure.sub_id, 
      {'effective_date'=>@vendor.effective_date, 'test_id'=>@vendor._id})
    @result = {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?', 'population' => '?', 'antinumerator' => '?'}
    if report.calculated?
      @result = report.result
    elsif patient_gen_status.completed?
      report.calculate
    end
    @result['measure_id'] = @measure.id.to_s
    
    respond_to do |format|
      format.json { render :json => @result }
      format.html { render :action => "show" }
    end
  end
  
  def patients
    @vendor = Vendor.find(params[:vendor_id])
    @measure = Measure.find(params[:id])
    patient_gen_status = Resque::Status.get(@vendor.patient_gen_job)
    report = QME::QualityReport.new(@measure['id'], @measure.sub_id, 
      {'effective_date'=>@vendor.effective_date, 'test_id'=>@vendor._id})
    @result = {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?', 'population' => '?', 'antinumerator' => '?'}
    if report.calculated?
      @result = report.result
    elsif patient_gen_status.completed?
      report.calculate
    end
    @result['measure_id'] = @measure.id.to_s
    @patients = Result.where("value.test_id" => @vendor.id).where("value.measure_id" => @measure['id'])
      .where("value.sub_id" => @measure.sub_id)
      .order_by([["value.numerator", :desc],["value.denominator", :desc],["value.exclusions", :desc]])    
  end
end
