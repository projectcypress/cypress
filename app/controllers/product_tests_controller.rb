class ProductTestsController < ApplicationController
  before_action :set_product, only: [:index, :new, :create]
  before_action :set_product_test, except: [:index, :new, :create]
  add_breadcrumb 'Dashboard', :vendors_path

  def index
    @product_tests = @product.product_tests
  end

  def edit
  end

  def update
  end

  def show
    return unless @product_test[:_type] == 'MeasureTest'
    if @product_test.tasks.c1_task
      redirect_to new_task_test_execution_path(@product_test.tasks.c1_task)
    elsif @product_test.tasks.c2_task
      redirect_to new_task_test_execution_path(@product_test.tasks.c2_task)
    end
  end

  def destroy
  end

  # Save and serve up the Records associated with this ProductTest. Filetype is specified by :format
  def download
    format = params[:format] || 'qrda'
    file = Cypress::CreateDownloadZip.create_test_zip(@product_test.id, format)
    file_name = "#{@product_test.cms_id}_#{@product_test.id}.#{format}.zip".tr(' ', '_')
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: file_name
  end
end
