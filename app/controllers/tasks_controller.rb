class TasksController < ApplicationController
  include API::Controller

  before_action :set_task, only: [:edit, :update, :destroy, :show, :good_results]
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

  def good_results
    redirect_to(:back) && return unless Cypress::AppConfig['enable_debug_features']
    task_type = @task._type
    redirect_to(:back) && return if %w(C3Cat1Task C3Cat3Task).include? task_type

    file_type = if %w(C1Task Cat1FilterTask).include? task_type
                  'zip'
                elsif %w(C2Task Cat3FilterTask).include? task_type
                  'xml'
                end

    file_content = @task.good_results
    pt = @task.product_test
    file_name = "#{pt.cms_id}_#{pt.id}.debug.#{file_type}".tr(' ', '_')

    send_data file_content, type: "application/#{file_type}", disposition: 'attachment', filename: file_name
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
