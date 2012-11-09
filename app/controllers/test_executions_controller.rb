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
    @te = @product_test.execute(params[:test_execution])
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
  
  def download
    te = TestExecution.find(params[:id])

    pdf = Cypress::PdfGenerator.generate_for(te)
     
    # Get the set of patient records for the test

    # Create a zip file of the patients and the pdf 
    file = Tempfile.new("results.zip")
    Zip::ZipFile.open(file.path) do |zip|
      zip.add("results.pdf", pdf.path)
    end

    send_file file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "results.zip"
  end
  
  private 
  
  def template_name(te)
    te.product_test.class.to_s.underscore
  end
  
end