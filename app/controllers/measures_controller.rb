class MeasuresController < ApplicationController
  before_filter :authenticate_user!

  def show
    @vendor = Vendor.find(params[:vendor_id])
    @test = @vendor.tests.find(params[:test_id])
    @measure = Measure.find(params[:id])
    patient_gen_status = Resque::Status.get(@test.patient_gen_job)
    report = QME::QualityReport.new(@measure['id'], @measure.sub_id, 
      {'effective_date'=>@test.effective_date, 'test_id'=>@test._id})
    @result = {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?'}
    if report.calculated?
      @result = report.result
    elsif patient_gen_status.completed?
      report.calculate
    end
    
    respond_to do |format|
      format.json { render :json => @result }
      format.html { render :action => "show" }
    end
  end
end
