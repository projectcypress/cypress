class TestExecutionsController < ApplicationController
  HTML_EXPORTER =  HealthDataStandards::Export::HTML.new
  #TODO Replace action_cache for download action with fragment/other caching

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
    begin
      @te = @product_test.execute(params[:test_execution])
      if @te.passed?
        flash[:success] = "Test Passed"
      else
        flash[:info] = "Test detected errors with submission"
      end
      redirect_to product_test_path(@te.product_test,:test_execution_id=>@te.id)
    rescue ArgumentError => e
      flash[:error] = e.message
      redirect_to product_test_path(@product_test)
    end


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
