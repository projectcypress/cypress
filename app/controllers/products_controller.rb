class ProductsController < ApplicationController
  before_filter :authenticate_user!
  
  rescue_from Mongoid::Errors::Validations do
     render :template => "products/edit"
   end
   
  def show
    @product = Product.find(params[:id])
  end
  
  def new
    @product = Product.new
    @product.vendor = Vendor.find(params[:vendor])
    
    @measures_categories = Measure.measure_categories
  end
  
  def create
    @product = Product.new(params[:product])
    @product.save!
    
    redirect_to vendor_path(@product.vendor.id)
  end
  
  def edit
    @product = Product.find(params[:id])
    @measures_categories = Measure.measure_categories
  end
  
  def update
    @product = Product.find(params[:id])
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