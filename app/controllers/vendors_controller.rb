class VendorsController < ApplicationController

  def index
    @incomplete_vendors = Vendor.all(:conditions => {'passed'=>{'$in'=>[nil,false]}})
    @complete_vendors = Vendor.all(:conditions => {'passed'=>true})
  end
  
  def new
    @vendor = Vendor.new
  end
  
  def create
    vendor = Vendor.new(params[:vendor])
    test = Test.new(:effective_date=>Time.gm(2010,12,31).to_i)
    vendor.tests << test
    vendor.save
    redirect_to :action => 'index'
  end
end
