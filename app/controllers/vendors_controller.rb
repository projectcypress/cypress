class VendorsController < ApplicationController
  before_filter :authenticate_user!

  def index
    passing_vendors = []
    failing_vendors = []
    
    Vendor.all.each do |vendor|
      if !vendor.products.empty? && vendor.passing?
        passing_vendors << vendor
      else
        failing_vendors << vendor
      end
    end
    
    @vendors = { 'fail' => failing_vendors, 'pass' => passing_vendors }
  end
  
  def new
    @vendor = Vendor.new
  end
  
  def create
    vendor = Vendor.new(params[:vendor])
    vendor.save!
    
    redirect_to root_path
  end
  
  def show
    @vendor = Vendor.find(params[:id])
    
    failing_products = @vendor.failing_products
    passing_products = @vendor.passing_products
    
    @products = { 'fail' => failing_products, 'pass' => passing_products }
  end
  
  def edit
    @vendor = Vendor.find(params[:id])
  end
  
  def destroy
    vendor = Vendor.find(params[:id])
    #delete all products for vendor
    Product.where(:vendor_id=>vendor.id).each do |product|
      #all tests for product
      ProductTest.where(:product_id=>product.id).each do |test|
       # Get rid of all related Records to this test
        Record.where(:test_id => test.id).each do |record|
          MONGO_DB.collection('patient_cache').remove({'value.patient_id' => record.id})
          record.destroy
        end
        # Get rid of all related executions
        test.test_executions.each do |execution|
          execution.destroy
        end

      end
    end
    vendor.destroy
    
    redirect_to root_path
  end
  
  def update
    vendor = Vendor.find(params[:id])
    vendor.update_attributes(params[:vendor])
    vendor.save!
   
    redirect_to vendor_path(vendor)
  end
end