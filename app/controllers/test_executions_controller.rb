class TestExecutionsController < ApplicationController
  before_action :set_test_execution, only: [:show, :destroy]
  before_action :set_task, only: [:index, :new, :create, :show]
  before_action :set_product_test, only: [:show, :new]
  before_action :add_breadcrumbs, only: [:show, :new]

  respond_to :html, :json, :xml
  respond_to :js, only: [:show]

  def index
    @test_executions = @task.test_executions
    respond_with(@test_executions)
  end

  def create
    authorize! :execute_task, @task.product_test.product.vendor
    @test_execution = @task.execute(params[:results])
    respond_with(@test_execution) do |f|
      f.html { redirect_to task_test_execution_path(task_id: @task.id, id: @test_execution.id) }
      f.json { render :nothing => true, :status => :created, :location => task_test_execution_path(@task.id, @test_execution.id) }
      f.xml  { render :nothing => true, :status => :created, :location => task_test_execution_path(@task.id, @test_execution.id) }
    end
  rescue Mongoid::Errors::Validations
    alert = 'Invalid file upload. Please make sure you upload an XML or zip file.'
    respond_with(@test_execution) do |f|
      f.html { redirect_to new_task_test_execution_path(task_id: @task.id), flash: { alert: alert.html_safe } }
      f.json { render :nothing => true, :status => :unprocessable_entity }
      f.xml  { render :nothing => true, :status => :unprocessable_entity }
    end
  end

  def new
    authorize! :execute_task, @task.product_test.product.vendor
    if @task.most_recent_execution
      redirect_to task_test_execution_path(task_id: @task.id, id: @task.most_recent_execution.id)
      return
    end
    render :show
  end

  def show
    authorize! :read, @task.product_test.product.vendor
    respond_with(@test_execution)
  end

  def destroy
    authorize! :delete, @test_execution.task.product_test.product.vendor
    @test_execution.destroy!
    render :nothing => true, status: :no_content
  end

  private

  def set_product_test
    @product_test = @task.product_test
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
