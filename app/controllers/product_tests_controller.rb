class ProductTestsController < ApplicationController
  before_action :set_product, only: [:index, :new, :create]
  before_action :set_product_test, except: [:index, :new, :create]

  def index
    @product_tests = @product.product_tests
  end

  def edit
  end

  def update
  end

  def show
    return unless @product_test[:_type] == 'MeasureTest'
    if @product_test.c1_task
      redirect_to "/tasks/#{@product_test.c1_task.id}/test_executions/new"
    elsif @product_test.c2_task
      redirect_to "/tasks/#{@product_test.c2_task.id}/test_executions/new"
    end
  end

  def destroy
  end

  # Save and serve up the Records associated with this ProductTest. Filetype is specified by :format
  def download
    format = params[:format] || 'qrda'
    file = Cypress::CreateDownloadZip.create_test_zip(@product_test.id, format)
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "Test_#{params[:id]}._#{format}.zip"
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_product_test
    @product_test = ProductTest.find(params[:id])
  end
end
