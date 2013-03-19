require 'open-uri'
require 'active_support'

class ProductTestsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @test = ProductTest.find(params[:id])
    @test_execution = TestExecution.find(params[:test_execution_id]) if params[:test_execution_id]
  end
  
  def new
    @product = Product.find(params[:product_id])
    @vendor = @product.vendor
    @test =  @product.product_tests.build
  end
  
  def create
    test = test_type(params[:type]).new(params[:product_test])
    test.user = current_user
    test.bundle = Bundle.find(params[:bundle_id])
    test.save!
    redirect_to product_path(test.product)
  end
  
  def edit
    @test = ProductTest.find(params[:id])
    @product = @test.product
    @vendor = @product.vendor
  end
  
  def update
    test = ProductTest.find(params[:id])
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
  
  def generate_cat1_test
    test = ProductTest.find(params[:id])
    qrda = test.generate_qrda_cat1_test
    redirect_to product_test_path(qrda)
  end

  def status
   @test = ProductTest.find(params[:id])
   @test_execution = TestExecution.find(params[:test_execution_id]) if params[:test_execution_id]
  end

  def execute   
    @product_Test = ProductTest.find(params[:product_test_id])
    @te = @product_Test.execute(params)
    redirect_to action: :show, id: @te
  end

  # Send an e-mail to the Vendor POC with an attachment that contains all of the Records included in this test
  def email
    test = ProductTest.find(params[:id])
    format = params[:format]
    
    UserMailer.send_records(test, format, params[:email]).deliver
    
    redirect_to :action => 'show'
  end
  
  # Save and serve up the Records associated with this ProductTest. Filetype is specified by :format
  def download
    test = ProductTest.find(params[:id])
    format = params[:format]
    file = Cypress::CreateDownloadZip.create_test_zip(test.id,format)
    send_file file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "Test_#{test.id}._#{format}.zip"
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
   
  def qrda_cat3
    @product_test = ProductTest.find(params[:id])
  end
end