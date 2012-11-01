
class PatientPopulationsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @patient_populations = PatientPopulation.any_in(:owner => [nil, current_user])
    respond_to do |format|
      format.json { render :json => @patient_populations }
      format.html { render :action => "show" }
    end
  end
  
  
  def download
    
    
  end
  
    
end
