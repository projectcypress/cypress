class TestExecutionsController < ApplicationController
  
  def new
    @te = TestExecution.new
    render template: "test_execution/#{template_name(te)}/new.html"
  end
  
  def show
    @te = TestExecution.find(params[:id])
    render template: "test_execution/#{template_name(te)}/show.html"
  end
  
  def create
    @product_Test = ProductTest.find(params[:product_test_id])
    @te=@product_Test.execute(params)
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