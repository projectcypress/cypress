class MeasuresController < ApplicationController
  before_filter :authenticate_user!

  def show
    @vendor = Vendor.find(params[:vendor_id])
    @test = @vendor.tests.find(params[:test_id])
    @measure = Measure.find(params[:id])
    report = QME::QualityReport.new(@measure['id'], @measure.sub_id, 
      {'effective_date'=>@test.effective_date, 'test_id'=>@test.id})
    @result = report.result
    @result ||= {'numerator' => '?', 'denominator' => '?', 'exclusions' => '?'}
  end
end
