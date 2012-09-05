class VendorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_vendor , :only=>[:show, :destroy, :edit, :update]

  rescue_from Mongoid::Errors::Validations do
     render :template => "vendors/edit"
   end
   
   
  def index
    @vendors = Vendor.all
    respond_to do |f|
      f.json {render :json=> @vendors }
      f.html {}
    end    
  end
  
  def new
    @vendor = Vendor.new
  end
  
  def create
    @vendor = Vendor.new params[:vendor]
    @vendor.save!
    respond_to do |f|
      f.json {redirect_to vendor_url(@vendor)}
      f.html { redirect_to root_path}
    end
   
  end
  
  def show
    respond_to do |f|
      f.json { render json: @vendor}
      f.html {}
    end
  end
  
  def edit
   # binding.pry
  end

  def destroy
    @vendor.destroy
    respond_to do |f|
      f.json { render :text=>"", :status=>201}
      f.html {redirect_to root_path}
    end 
  end
  
  def update
    @vendor.update_attributes(params[:vendor])
    unless @vendor.save
      render :template=>"vendor/edit"
    end
    
    redirect_to vendor_path(@vendor)
  end
  


private 

def find_vendor
  @vendor = Vendor.find(params[:id]||params[:vendor_id])
end

end