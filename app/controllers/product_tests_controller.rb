
require 'open-uri'
require 'prawnto'

class ProductTestsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @test = ProductTest.find(params[:id])
  end
  
  def new
    @test = ProductTest.new
    @product = Product.find(params[:product])
    @vendor = @product.vendor
    @effective_date = Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE
    @period_start = 3.months.ago(Time.at(@effective_date)).getgm
  end
  
  def create
    test = test_type.new(params[:product_test])
    test.save!
    redirect_to :action => 'show', :id => test.id, :default_format => default_format
  end
  
  def edit
    @test = current_user.product_tests.find(params[:id])
  end
  
  def update
    test = current_user.product_tests.find(params[:id])
    test.update_attributes(params[:product_test])
    test.save!
    redirect_to product_test_path(test)
  end
  
  def destroy
    test = current_user.product_tests.find(params[:id])
    test.destroy
    redirect_to product_path(product)
  end

  # Send an e-mail to the Vendor POC with an attachment that contains all of the Records included in this test
  def email
    test = ProductTest.find(params[:id])
    format = params[:format]
    
    UserMailer.send_records(test, format).deliver
    
    redirect_to :action => 'show'
  end
  
  # Save and serve up the Records associated with this ProductTest. Filetype is specified by :format
   def download
     test = current_user.product_tests.find(params[:id])
     format = params[:format]
     file = Cypress::CreateDownloadZip.create_test_zip(test.id,format)

     if format == 'csv'
       send_file file.path, :type => 'text/csv', :disposition => 'attachment', :filename => "Test_#{test.id}.csv"
     else
       send_file file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "Test_#{test.id}._#{format}.zip"
     end

     file.close
   end

  
private

  def test_type
    params[:type].constintize
  end

 

end
