class ProductTestsController < ApplicationController
<<<<<<< HEAD
  before_action :set_product, only: [:index, :new, :create]
  before_action :set_product_test, only: [:edit, :update, :destroy, :show]

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
