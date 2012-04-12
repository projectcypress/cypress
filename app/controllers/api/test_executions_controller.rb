module Api
  class TestExecutionsController < ApiController
    before_filter :authenticate_user!
    before_filter :find_product_test
    before_filter :find_test_execution, :only=>[:show, :destroy]
    respond_to :json
    def index
      @test_executions = @product_test.test_executions
      render json:@test_executions
    end
    
    def create
      blr = params[:baseline_results] ? Cypress::PqriUtility.extract_results(params[:baseline_results].read) : nil
      rr = params[:reported_results] ? Cypress::PqriUtility.extract_results(params[:reported_results].read) : nil
      
      blve = params[:baseline_results] ? Cypress::PqriUtility.validate(params[:baseline_results].read) : nil
      ve = params[:reported_results] ? Cypress::PqriUtility.validate(params[:reported_results].read) : nil
      
      te = TestExecution.new(baseline_results:blr, reported_results: rr, baseline_validation_errors:blve, validation_errors:ve)
      te.save
      redirect_to api_vendor_product_product_test_test_execution_url(@vendor,@product,@product_test,te)
    end
    
    def show
      render json:@test_execution
    end
    
    def destroy
      @test_execution.destroy
      render text: "", status:201
    end
    
   private 
   
   def find_test_execution
     @test_execution = TestExecution.find(params[:id])
   end
  
  end
  
end