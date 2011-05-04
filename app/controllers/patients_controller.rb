class PatientsController < ApplicationController

  before_filter do
    if params[:vendor_id]
      @vendor = {}
    end
  end
  
  def index
    @patients = mongo['records'].find.to_a
  end
  
  def show
    patient_id = BSON::ObjectId.from_string(params[:id])
    @patient = mongo['records'].find_one({:_id => patient_id})
    @results = mongo['patient_cache'].find({'value.patient_id' => patient_id}, 
      :sort => [['value.measure_id', :asc], ['value.sub_id', :asc]]).to_a
  end
end
