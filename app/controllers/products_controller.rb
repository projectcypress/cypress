class ProductsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @product = Product.find(params[:id])
    @vendor = @product.vendor
    
    failing_tests = @product.failing_tests
    passing_tests = @product.passing_tests
    
    @tests = { 'fail' => failing_tests, 'pass' => passing_tests }
  end
  
  def new
    @vendor = Vendor.find(params[:vendor])
    @product = Product.new
  end
  
  def create
    product = Product.new(params[:product])
    product.save!
    
    redirect_to vendor_path(params[:product][:vendor_id])
  end
  
  def edit
    @product = Product.find(params[:id])
    @vendor = @product.vendor
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
end