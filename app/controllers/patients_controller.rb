class PatientsController < ApplicationController

  before_filter :authenticate_user!

  before_filter do
    if params[:vendor_id]
      @vendor = {}
    end
    if params[:test_id]
      @test = {}
    end
  end
  
  def index
    @patients = Record.all(:limit => 50)
  end
  
  def show
    patient_id = BSON::ObjectId.from_string(params[:id])
    @patient = Record.find(params[:id])
    @results = Result.all(:conditions => {'value.patient_id' => patient_id}, 
      :sort => [['value.measure_id', :asc], ['value.sub_id', :asc]])
  end
end
