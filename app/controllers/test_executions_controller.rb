class TestExecutionsController < ApplicationController
  
  def new
    @test_execution = TestExecution.new
    render template: "test_executions/#{template_name(te)}/new.html"
  end
  
  def show
    @test_execution = TestExecution.find(params[:id])
     respond_to do |format|
      # Don't send tons of JSON until we have results. In the meantime, just update the client on our calculation status.
      format.js 
      format.html      
      format.pdf { render :layout => false }
      prawnto :filename => "#{@test_execution.product_test.name}.pdf"
    end
  end
  
  def create

    @product_test = ProductTest.find(params[:product_test_id])
    @te=@product_test.execute(params[:test_execution])
    redirect_to product_test_path(@te.product_test,:test_execution_id=>@te.id)
  end
  
  def destroy
    te = TestExecution.find(params[:id])
    te.destroy
    if params[:product_id]
      redirect_to product_url(te.product_test.product)
    else
      redirect_to product_test_url(te.product_test)
    end
    
  end
  
  def results

     te = TestExecution.find(params[:id])
     # obtain the report as a pdf
     pdf = 
     #get the set of patient records for the test
     patients = 

     # create a zip file of the patients and the pdf 

     # send the zip file back to the user

    Zip::ZipFile.open(".tmp/#{te.id}_#{time.now.to_i}.zip", Zip::ZipFile::CREATE) do |zipfile|
     zipfile.get_output_stream("records.zip") { |f| f.puts te.generate_patient_zip("ccda") }
     zipfile.get_output_stream("report.pdf") {|f| f.puts ""}
    end
  end
  
  private 
  
  def template_name(te)
    te.product_test.class.to_s.underscore
  end
  
end