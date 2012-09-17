class TestExecutionsController < ApplicationController
  
  def new
    @te = TestExecution.new
    render template: "test_executions/#{template_name(te)}/new.html"
  end
  
  def show
    @test_execution = TestExecution.find(params[:id])
    # respond_to do | format |  
    #            format.js {render :layout => false,template: "test_executions/#{template_name(@te)}/show"}  
    #            format.html {render template: "test_executions/#{template_name(@te)}/show"}
    #        end
    
  end
  
  def create
    @product_test = ProductTest.find(params[:product_test_id])
    @te=@product_test.execute(params[:test_execution])
    redirect_to action: :show, id: @te
  end
  
  def destroy
    te = TestExecution.find(params[:id])
    if te.destroy
      redirect_to product_test_url(te.product_test)
    else
      redirect_to product_test_url(te.product_test)
    end
    
  end
  
  
  private 
  
  def template_name(te)
    te.product_test.class.to_s.underscore
  end
  
end