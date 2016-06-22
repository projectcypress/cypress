class ProductsController < ApplicationController
  include API::Controller
  before_action :set_vendor, only: [:index, :new, :create, :report, :patients]
  before_action :set_product, except: [:index, :new, :create]
  before_action :set_measures, only: [:new, :edit, :update, :report]
  before_action :authorize_vendor
  add_breadcrumb 'Dashboard', :vendors_path

  respond_to :html, except: [:index]
  respond_to :json, :xml, except: [:new, :edit, :update]

  def index
    @products = @vendor.products
    respond_with(@products.to_a)
  end

  def show
    add_breadcrumb 'Vendor: ' + @product.vendor.name, vendor_path(@product.vendor)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor, @product)
    respond_with(@product, &:js)
  end

  def new
    @product = Product.new(vendor: @vendor)
    setup_new
  end

  def create
    @product = @vendor.products.new
    @product.update_with_measure_tests(product_params)
    @product.save!
    flash_comment(@product.name, 'success', 'created')
    respond_with(@product) do |f|
      f.html { redirect_to vendor_path(@vendor) }
    end
  rescue Mongoid::Errors::Validations, Mongoid::Errors::DocumentNotFound
    respond_with_errors(@product) do |f|
      f.html do
        setup_new
        @selected_measure_ids = product_params['measure_ids']
        render :new
      end
    end
  end

  def edit
    add_breadcrumb 'Vendor: ' + @product.vendor.name, vendor_path(@product.vendor)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor, @product)
    add_breadcrumb 'Edit Product', :edit_vendor_path
    @selected_measure_ids = @product.measure_ids
  end

  def update
    @product.update_with_measure_tests(edit_product_params)
    @product.save!
    flash_comment(@product.name, 'info', 'edited')
    respond_with(@product) do |f|
      f.html { redirect_to vendor_path(@product.vendor) }
    end
  rescue Mongoid::Errors::Validations, Mongoid::Errors::DocumentNotFound
    respond_with(@product) do |f|
      f.html do
        @selected_measure_ids = product_params['measure_ids']
        render :edit
      end
    end
  end

  def destroy
    @product.destroy
    flash_comment(@product.name, 'danger', 'removed')
    respond_with(@product) do |f|
      f.html { redirect_to vendor_path(@product.vendor) }
    end
  end

  # always responds with a pdf file containing information on the certification status of the product
  def report
  end

  # always responds with a zip file of (.qrda.zip files of (qrda category I documents))
  def patients
    file = Cypress::CreateDownloadZip.create_total_test_zip(@product, 'qrda')
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "#{@product.name}_#{@product.id}.zip".tr(' ', '_')
  end

  private

  def authorize_vendor
    vendor = @vendor || @product.vendor
    authorize_request(vendor, read: %w(report patients))
  end

  def set_measures
    @bundle = (@product && @product.bundle) ? @product.bundle : Bundle.default
    @measures = @bundle ? @bundle.measures.top_level.only(:cms_id, :sub_id, :name, :category, :hqmf_id, :type) : []
    @measures_categories = @measures.group_by(&:category)
  end

  def setup_new
    add_breadcrumb 'Vendor: ' + @vendor.name, vendor_path(@product.vendor)
    add_breadcrumb 'Add Product', :new_vendor_path
    set_measures
    params[:action] = 'new'
  end

  def product_params
    params.require(:product).permit(:name, :version, :description, :randomize_records, :duplicate_records, :bundle_id, :measure_selection,
                                    :c1_test, :c2_test, :c3_test, :c4_test, measure_ids: [])
  end

  def edit_product_params
    params.require(:product).permit(:name, :version, :description, :measure_selection, measure_ids: [])
  end
end
