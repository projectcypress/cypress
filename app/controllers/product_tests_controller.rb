class ProductTestsController < ApplicationController
  before_action :set_product, only: [:index]
  before_action :set_product_test, except: [:index]
  before_action :authorize_vendor, only: [:index, :show, :patients]
  add_breadcrumb 'Dashboard', :vendors_path

  def index
    @product_tests = @product.product_tests
  end

  def show
    return unless @product_test[:_type] == 'MeasureTest'
    if @product_test.tasks.c1_task
      redirect_to new_task_test_execution_path(@product_test.tasks.c1_task)
    elsif @product_test.tasks.c2_task
      redirect_to new_task_test_execution_path(@product_test.tasks.c2_task)
    end
  end

  # always respond with a .qrda.zip file of qrda category I documents
  def patients
    file_name = "#{@product_test.cms_id}_#{@product_test.id}.qrda.zip".tr(' ', '_')
    send_data @product_test.patient_archive.read, type: 'application/zip', disposition: 'attachment', filename: file_name
  end

  private

  def authorize_vendor
    vendor = @product ? @product.vendor : @product_test.product.vendor
    authorize_request(vendor, read: ['patients'])
  end
end
