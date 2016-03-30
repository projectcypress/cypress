class TasksController < ApplicationController
  include API::Controller

  before_action :set_task, only: [:edit, :update, :destroy, :show]
  before_action :set_product_test, only: [:index, :new]
  before_action :authorize_vendor

  respond_to :html, only: []

  add_breadcrumb 'Dashboard', :vendors_path

  class TypeNotFound < StandardError
  end

  rescue_from TypeNotFound do |exception|
    render text: exception, status: 500
  end

  def index
    # only get C1, C2, and C4 tasks (no C3)
    @tasks = @product_test.tasks.any_in(_type: %w(C1Task C2Task Cat1FilterTask Cat3FilterTask))
    respond_with(@tasks.to_a)
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
