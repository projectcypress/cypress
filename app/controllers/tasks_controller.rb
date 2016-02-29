class TasksController < ApplicationController
  before_action :set_task, only: [:edit, :update, :destroy, :show]
  before_action :set_product_test, only: [:index, :new, :create] # <-- remove :create
  before_action :authorize_vendor

  respond_to :html, :json, :xml

  add_breadcrumb 'Dashboard', :vendors_path

  class TypeNotFound < StandardError
  end

  rescue_from TypeNotFound do |exception|
    render text: exception, status: 500
  end

  def index
    @tasks = @product_test.tasks
    respond_with(@tasks)
  end

  def show
    respond_with(@task)
  end

  private

  def authorize_vendor
    vendor = @product_test ? @product_test.product.vendor : @task.product_test.product.vendor
    authorize_request(vendor)
  end

  def task_type(type)
    type.camelize.constantize
  rescue
    raise TypeNotFound, "#{type} could not be created"
  end
end
