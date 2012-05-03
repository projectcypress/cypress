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
    measures = params[:product][:measure_map]
    measure_map = {}
    measures.each do |m|
      measure_map[m] = params[m][m]
    end
    params[:product][:measure_map] = measure_map
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