class TasksController < ApplicationController
  before_action :set_task, only: [:edit, :update, :destroy, :show]
  before_action :set_product_test, only: [:index, :new, :create]
  add_breadcrumb 'Dashboard', :vendors_path
  class TypeNotFound < StandardError
  end

  rescue_from TypeNotFound do |exception|
    render text: exception, status: 500
  end
  def index
    @tasks = @product_test.tasks
  end

  def new
    @task = @product_test.tasks.build({}, task_type(params[:type]))
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
  end

  def destroy
    @task.destroy
    render status: 204, text: 'Deleted'
  end

  private

  def authorize_vendor(vendor)
    authorize! :manage, vendor if params[:action] != :show
    authorize! :read, vendor if params[:action] == :show
  end

  def set_product_test
    @product_test = ProductTest.find(params[:product_test_id])
    authorize_vendor(@product_test.product.vendor)
  end

  def set_task
    @task = Task.find(params[:id])
    authorize_vendor(@task.product_test.product.vendor)
  end

  def task_type(type)
    type.camelize.constantize
  rescue
    raise TypeNotFound, "#{type} could not be created"
  end
end
