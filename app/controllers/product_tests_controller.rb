class ProductTestsController < ApplicationController
  before_action :set_product, only: [:index, :new, :create]
  before_action :set_product_test, except: [:index, :new, :create]

  def index
    @product_tests = @product.product_tests
  end

  def new
    @product_test = @product.product_tests.build({})
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
    @vendor = @product_test.product.vendor
    add_breadcrumb @vendor.name, [@vendor]
    add_breadcrumb @product_test.product.name, [@vendor, @product_test.product]
    add_breadcrumb @product_test.name, [@product_test.product, @product_test]
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
