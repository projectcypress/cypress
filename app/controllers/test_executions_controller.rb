class TestExecutionsController < ApplicationController
  before_action :set_test_execution, only: [:destroy, :show]
  before_action :set_task, only: [:new, :create, :show]
  before_action :set_product_test, only: [:show, :new]
  before_action :add_breadcrumbs, only: [:show, :new]

  def create
    @test_execution = @task.execute(params[:results])
    redirect_to task_test_execution_path(task_id: @task.id, id: @test_execution.id)
  rescue Mongoid::Errors::Validations
    alert = 'Invalid file upload. Please make sure you upload an XML or zip file.'
    redirect_to new_task_test_execution_path(task_id: @task.id), flash: { alert: alert.html_safe }
  end

  def new
    if @task.most_recent_execution
      redirect_to task_test_execution_path(task_id: @task.id, id: @task.most_recent_execution.id)
      return
    end
    render :show
  end

  def show
    respond_to do |f|
      f.html
      f.js
    end
  end

  def destroy
    @test_execution.destroy
    render status: 204, text: 'Deleted'
  end

  private

  def set_product_test
    @product_test = @task.product_test
  end

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_test_execution
    @test_execution = TestExecution.find(params[:id])
  end

  def add_breadcrumbs
    add_breadcrumb 'Vendor: ' + @product_test.product.vendor.name, vendor_path(id: @product_test.product.vendor.id)
    add_breadcrumb 'Product: ' + @product_test.product.name, vendor_product_path(vendor_id: @product_test.product.vendor.id,
                                                                                 id: @product_test.product.id)
    add_breadcrumb 'Test: ' + @product_test.name, product_product_test_path(product_id: @product_test.product.id,
                                                                            id: @product_test.id)
  end
end
