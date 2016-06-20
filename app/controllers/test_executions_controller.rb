class TestExecutionsController < ApplicationController
  include API::Controller

  before_action :set_test_execution, only: [:show, :destroy]
  before_action :set_task, only: [:index, :new, :create]
  before_action :set_task_from_test_execution, only: [:show]
  before_action :set_product_test_from_task, only: [:show, :new]
  before_action :add_breadcrumbs, only: [:show, :new]

  respond_to :js, only: [:show]

  def index
    @test_executions = @task.test_executions
    respond_with(@test_executions.to_a)
  end

  def create
    authorize! :execute_task, @task.product_test.product.vendor
    @test_execution = @task.execute(results_params)
    respond_with(@test_execution) do |f|
      f.html { redirect_to task_test_execution_path(task_id: @task.id, id: @test_execution.id) }
    end
  rescue Mongoid::Errors::Validations
    rescue_create
  end

  def new
    authorize! :execute_task, @product_test.product.vendor
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
    render :nothing => true, :status => :no_content
  end

  private

  def rescue_create
    alert = 'Invalid file upload. Please make sure you upload an XML or zip file.'
    error_response = { errors: [{ field: 'results',
                                  messages: ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III'] }] }
    respond_with(@test_execution) do |f|
      f.html { redirect_to new_task_test_execution_path(task_id: @task.id), flash: { alert: alert.html_safe } }
      f.json { render :json => error_response, :status => :unprocessable_entity }
      f.xml  { render :xml => error_response[:errors].to_xml(:root => :errors, :skip_types => true), :status => :unprocessable_entity }
    end
  end

  def set_task_from_test_execution
    @task = @test_execution.task
  end

  def set_product_test_from_task
    @product_test = @task.product_test
  end

  def add_breadcrumbs
    add_breadcrumb 'Dashboard', :vendors_path
    add_breadcrumb 'Vendor: ' + @product_test.product.vendor.name, vendor_path(@product_test.product.vendor)
    add_breadcrumb 'Product: ' + @product_test.product.name, vendor_product_path(@product_test.product.vendor, @product_test.product)
    add_breadcrumb 'Test: ' + @product_test.name, product_product_test_path(@product_test.product, @product_test)
  end

  def results_params
    params[:results]
  end
end
