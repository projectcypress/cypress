class VendorsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @incomplete_vendors = []
    @complete_vendors = []
    vendors = Vendor.all
    vendors.each do |vendor|
      if vendor.passing?
        @complete_vendors << vendor
      else
        @incomplete_vendors << vendor
      end
    end
  end
  
  def new
    @vendor = Vendor.new
  end
  
  def create
    # We can't save this file with the vendor model so save it so we can pull it out
    uploaded_file = params[:vendor][:byod].tempfile unless !params[:vendor][:byod]
    params[:vendor].delete('byod')
    
    # Create a new vendor and save here so _id is made
    vendor = Vendor.new(params[:vendor])
    vendor.save!
    
    #if uploaded_file
    #  # If the user brought their own data, tell PIJ where to find the uploaded file
    #  byod_path = "/tmp/byod_#{vendor.id}_#{Time.now.to_i}"
    #  File.rename(File.path(uploaded_file), byod_path)
    #  Cypress::PatientImportJob.create(:zip_file_location => byod_path, :test_id => vendor._id)
    #else
    #  # Otherwise we're making a subset of the Test Deck
    #  Cypress::TDSubsetJob.create(:subset_id => params[:vendor][:patient_population_id], :test_id => vendor._id)  
    #end
    
    redirect_to :action => 'show', :id => vendor.id
  end
  
  def show
    @vendor = Vendor.find(params[:id])
    @incomplete_products = @vendor.failing_products
    @complete_products = @vendor.passing_products
  end
  
  def edit
    @vendor = Vendor.find(params[:id])
  end
  
  def destroy
    vendor = Vendor.find(params[:id])    
    Record.where(:test_id => vendor.id).delete

    vendor.products.each do |product|
      product.destroy
    end
    vendor.destroy
    
    redirect_to :action => :index
  end
  
  def update
    @vendor = Vendor.find(params[:id])
    @vendor.update_attributes(params[:vendor])
    @vendor.save!
   
    redirect_to :action => 'show'
  end
end
