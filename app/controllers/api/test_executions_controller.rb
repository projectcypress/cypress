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
      
      bl = params[:baseline_results] ? params[:baseline_results].read : nil
      er = params[:reported_results] ? params[:reported_results].read : nil
      
      blr = bl ? Cypress::PqriUtility.extract_results(bl) : nil
      rr = er ? Cypress::PqriUtility.extract_results(er) : nil
      
      blve = bl ? Cypress::PqriUtility.validate(bl) : nil
      ve = er ? Cypress::PqriUtility.validate(er) : nil
      
      te = TestExecution.new(baseline_results:blr, reported_results: rr, baseline_validation_errors:blve, validation_errors:ve, execution_date:Time.now.to_i)
      te.save
      redirect_to api_vendor_product_product_test_test_execution_url(@vendor,@product,@product_test,te)
    end
    
    def show
      render json: @test_execution
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