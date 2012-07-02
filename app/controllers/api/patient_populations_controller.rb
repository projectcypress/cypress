module Api
  class PatientPopulationsController < ApiController
    before_filter :authenticate_user!
    before_filter :find_patient_population , only:[:show,:destroy]
    respond_to :json
    
    def index
      
    end
    
    def create
      
    end
    
    def show
      
    end
    
    def destroy
      
    end
    
  end
  
end