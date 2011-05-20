class MeasuresController < ApplicationController
  def show
    @vendor = Vendor.find(params[:vendor_id])
    @test = @vendor.tests.find(params[:test_id])
    @measure = Measure.find(params[:id])
  end
end
