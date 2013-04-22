class TestExecutionsController < ApplicationController  
  HTML_EXPORTER =  HealthDataStandards::Export::HTML.new
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
  

  def visual_inspection
     te = TestExecution.find(params[:id])
     @measures = te.product_test.measures
     @file = te.artifact.get_file(params[:filename])
     @doc = Nokogiri::XML(@file)
     @doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
     @doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")
     patient = @doc.at_xpath("/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name")
     first_name = patient.at_xpath("./cda:given/text()").to_s
     last_name = patient.at_xpath("./cda:family/text()").to_s

     @record = te.product_test.records.where({first: first_name, last: last_name}).first
     
     @html = HTML_EXPORTER.export(@record)
     render :text=> @html
     # binding.pry
     # @elements = @doc.xpath("//@sdtc:valueSet").collect{|dc| dc.value}.uniq
  end

end