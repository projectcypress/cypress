module Api
  class MeasuresController < ApiController
    before_filter :authenticate_user!
    before_filter :find_measure, only:[:show, :destroy]
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