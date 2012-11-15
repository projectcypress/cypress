require 'open-uri'
require 'prawnto'
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
    @effective_date = Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE
    @period_start = 3.months.ago(Time.at(@effective_date)).getgm
  end
  
  def create
    test = test_type(params[:type]).new(params[:product_test])
    test.user = current_user
    test.save!
    redirect_to product_path(test.product)
  end
  
  def edit
    @test = ProductTest.find(params[:id])
    @product = @test.product
    @vendor = @product.vendor
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
  

  def status
    @test = ProductTest.find(params[:id])
    
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
   

  def qrda_cat3
    @product_test = ProductTest.find(params[:id])
  end
end