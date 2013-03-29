class TestExecutionsController < ApplicationController  

  caches_action :download

  def show
    @test_execution = TestExecution.find(params[:id])
     respond_to do |format|
      # Don't send tons of JSON until we have results. In the meantime, just update the client on our calculation status.
      format.js 
      format.html      
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
    test_execution = TestExecution.find(params[:id])
    zip = Cypress::PatientZipper.zip_artifacts(test_execution)    
    zip_name = "#{test_execution.product_test.name}-#{test_execution.id}.zip"
    send_file zip.path, :type => 'application/zip', :disposition => 'attachment', :filename => zip_name
  end
  

end