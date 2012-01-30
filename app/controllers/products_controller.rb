class ProductsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    
  end
  
  def show
    @product = Product.find(params[:id])
    @vendor = Vendor.find(params[:vendor_id])
    @incomplete_tests = @product.failing_tests
    @complete_tests = @product.passing_tests
  end
  
  def new
    @product = Product.new
    @vendor = Vendor.find(params[:vendor_id])
  end
  
  def create
    product = Product.new(params[:product])
    product.vendor_id = params[:vendor_id]
    product.save!
    
    redirect_to :action => 'show', :id => product.id
  end
  
  def edit
    @product = Product.find(params[:id])
    @vendor = Vendor.find(params[:vendor_id])
  end
  
  def update
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product])
    @product.save!
   
    redirect_to :action => 'show'
  end
  
  def destroy
    product = Product.find(params[:id])
    product.destroy
    
    redirect_to vendor_path(params[:vendor_id])
  end
end