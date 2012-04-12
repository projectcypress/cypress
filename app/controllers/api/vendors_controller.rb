module Api
  class VendorsController < ApiController
    before_filter :authenticate_user!
    before_filter :find_vendor , :only=>[:show,:update, :destroy]
    respond_to :json
   
    def index
       @vendors = current_user.vendors
       render :json=> @vendors
    end
    
    def create
      json = JSON.parse(request.body.read)
      @vendor = current_user.vendors.build json
      @vendor.save
      redirect_to api_vendor_url(@vendor)
      
    end
    
    def show
      render :json=>@vendor
    end
    
    
    def update
      json = JSON.parse(request.body.read)
      @vendor .update_attributes json
      @vendor.save
      redirect_to api_vendor_url(@vendor)
      
    end
    
    def destroy

      @vendor.destroy
      render :text=>"", :status=>201
    end
    
    
    private 
    
    def find_vendor
      @vendor = current_user.vendors.find(params[:id])
    end
 
  end
  
end
