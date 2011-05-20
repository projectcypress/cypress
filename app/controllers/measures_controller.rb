class MeasuresController < ApplicationController
  before_filter :authenticate_user!

  def show
    @vendor = Vendor.find(params[:vendor_id])
    @test = @vendor.tests.find(params[:test_id])
    @measure = Measure.find(params[:id])
  end
end
