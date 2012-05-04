class ProductsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_product, only: [:show,:edit,:update]
  
  rescue_from Mongoid::Errors::Validations do
    render :template => "products/edit"
  end
   
  def show
  end
  
  def new
    @product = Product.new
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

    @product = Product.new(params[:product])
    @product.save!
    
    redirect_to vendor_path(@product.vendor.id)
  end
  
  def edit
  end
  
  def update
    @product.update_attributes(params[:product])
    @product.save!
   
    redirect_to :action => 'show'
  end
  
  def destroy
    product = Product.find(params[:id])
    vendor = product.vendor
    product.destroy
    redirect_to vendor_path(vendor)
  end
  
  
  
  private
  
  def find_product
    @product = Product.find(params[:id] || params[:product_id])
  end
end