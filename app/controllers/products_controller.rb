class ProductsController < ApplicationController
  before_filter :authenticate_user!
  
  rescue_from Mongoid::Errors::Validations do
    render :template => "products/edit"
  end
   
  def show
  end
  
  def new
    @product = current_user.products.new
    @product.vendor = Vendor.find(params[:vendor])
  end
  
  def create

    # construct the measure mapping from the selections indicated by the user
    if params[:product] && params[:product][:measure_map]
      measure_keys = params[:product][:measure_map]
      measure_map = {}
      measure_keys.each { |m| measure_map[m] = params[m][m] }
      params[:product][:measure_map] = measure_map
    end

    @product = current_user.products.build(params[:product])
    @product.save!
    
    redirect_to vendor_path(@product.vendor.id)
  end
  
  def edit

    @product = current_user.products.find(params[:id])
  end
  
  def update
    @product = current_user.products.find(params[:id])
    @product.update_attributes(params[:product])
    @product.save!
   
    redirect_to :action => 'show'
  end
  
  def destroy
    product = current_user.products.find(params[:id])
    vendor = product.vendor
    product.destroy
    redirect_to vendor_path(vendor)
  end
  
  
  
  private
  
end