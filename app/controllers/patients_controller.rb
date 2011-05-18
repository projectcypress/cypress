class PatientsController < ApplicationController

  before_filter :authenticate_user!

  before_filter do
    @test_id = nil
    if params[:test_id]
      @test_id = nil # use the param once we have patient generation working
    elsif params[:vendor_id]
      # find the most recent test_id for the vendor
    end
  end
  
  def index
    @patients = Record.all(:conditions => {'test_id' => @test_id},
      :limit => 50)
  end
  
  def show
    patient_id = BSON::ObjectId.from_string(params[:id])
    @patient = Record.find(params[:id])
    @results = Result.all(:conditions => {'value.patient_id' => patient_id}, 
      :sort => [['value.measure_id', :asc], ['value.sub_id', :asc]])
  end
end
