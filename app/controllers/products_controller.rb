class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :destroy]
  before_action :set_vendor, only: [:new, :create, :edit, :update, :destroy]

  def new
    @product = Product.new
    @product.vendor = @vendor
    add_breadcrumb @vendor.name, "/vendors/#{@vendor.id}"
    add_breadcrumb 'Add Product', :new_vendor_path
  end

  def create
    @product = Product.new(product_params)
    @product.vendor = @vendor
    @product.save!
    flash_product_comment(@product.name, 'success', 'created')
    respond_to do |f|
      f.json {} # <-- must be fixed later
      f.html { redirect_to vendor_path(@vendor.id) }
    end
  rescue Mongoid::Errors::Validations
    render :new
  end

  def edit
    add_breadcrumb @vendor.name, "/vendors/#{@vendor.id}"
    add_breadcrumb 'Edit Product', :edit_vendor_path
  end

  def update
    @product.update_attributes(edit_product_params)
    @product.save!
    flash_product_comment(@product.name, 'info', 'edited')
    respond_to do |f|
      f.json {} # <-- must be fixed later
      f.html { redirect_to vendor_path(@vendor.id) }
    end
  rescue Mongoid::Errors::Validations
    render :edit
  end

  def destroy
    @product.destroy
    flash_product_comment(@product.name, 'danger', 'removed')
    respond_to do |format|
      format.json {} # <-- must be fixed later
      format.html { redirect_to vendor_path(@vendor.id) }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def set_vendor
    @vendor = Vendor.find(params[:vendor_id])
  end

  def product_params
    params[:product].permit(:name, :version, :description, :ehr_type, :c1_test, :c2_test, :c3_test, :c4_test)
  end

  def edit_product_params
    params[:product].permit(:name, :version, :description)
  end

  def flash_product_comment(product_name, notice_type, action_type)
    flash[:notice] = "Vendor '#{product_name}' was #{action_type}."
    flash[:notice_type] = notice_type
  end
end
