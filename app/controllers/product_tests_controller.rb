
require 'open-uri'
require 'prawnto'
require 'active_support'
class ProductTestsController < ApplicationController
  before_filter :authenticate_user!
  
  class TypeNotFound < StandardError
  end
  
  rescue_from TypeNotFound do |exception|
    render :text => exception, :status => 500
  end
  

  def show
    @test = ProductTest.find(params[:id])
  end
  
  def new
   
    @product = Product.find(params[:product_id])
    @vendor = @product.vendor
    @test =  @product.product_tests.build
    @effective_date = Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE
    @period_start = 3.months.ago(Time.at(@effective_date)).getgm
  end
  
  def create
    test = test_type.new(params[:product_test])
    test.save!
    redirect_to product_path(test.product)
  end
  
  def edit
    @product = Product.find(params[:product_id])
    @vendor = @product.vendor
    @test = @product.product_tests.find(params[:id])
  end
  
  def update
    test = current_user.product_tests.find(params[:id])
    test.update_attributes(params[:product_test])
    test.save!
    redirect_to product_test_path(test)
  end
  
  def destroy
    test = ProductTest.find(params[:id])
    product = test.product
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


  
  def delete_note
     test = ProductTest.find(params[:id])
     note = test.notes.find(params[:note][:id])
     note.destroy

     redirect_to :action => 'show', :execution_id => params[:execution_id]
   end

   def add_note
     test = ProductTest.find(params[:id])

     note = Note.new(params[:note])
     note.time = Time.now.getgm

     test.notes << note
     test.save!
     redirect_to :action => 'show', :execution_id => params[:execution_id]
   end
   
  
private

  def test_type

    raise TypeNotFound.new if params[:type].nil?
    params[:type].camelize.constantize
  end

 

end
