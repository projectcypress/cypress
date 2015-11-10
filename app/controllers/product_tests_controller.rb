class ProductTestsController < ApplicationController
  before_action :set_product, only: [:index, :new, :create, :show]
  before_action :set_product_test, only: [:edit, :update, :show, :destroy]

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
    @vendor = @product.vendor
    add_breadcrumb @vendor.name, [@vendor]
    add_breadcrumb @product.name, [@vendor, @product]
    add_breadcrumb @product_test.name, [@product, @product_test]
  end

  def destroy
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_product_test
    @product_test = ProductTest.find(params[:id])
  end
end
