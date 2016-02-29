require 'cypress/pdf_report'

class ProductsController < ApplicationController
  before_action :set_vendor, only: [:index, :new, :create, :report, :patients]
  before_action :set_product, except: [:index, :new, :create]
  before_action :set_measures, only: [:new, :update, :edit]
  before_action :authorize_vendor
  add_breadcrumb 'Dashboard', :vendors_path

  respond_to :html, :json, :xml

  def index
    @products = @vendor.products
    respond_with(@products)
  end

  def show
    add_breadcrumb 'Vendor: ' + @product.vendor.name, vendor_path(@product.vendor)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor, @product)
    respond_with(@product)
  end

  def new
    @product = Product.new(vendor: @vendor)
    setup_new
    respond_with(product: @product, measures: @measures, measure_categories: @measure_categories)
    # respond_to do |format|
    #   format.html
    #   format.json { render json: { measures: @measures, measures_categories: @measures_categories, product: @product } }
    # end
  end

  def create
    @product = Product.new(product_params)
    @product.vendor = @vendor
    # TODO: Refactor this so we can't save products without measures in more concise code
    if params['product_test'] && params['product_test']['measure_ids']
      @product.add_product_tests_to_product(params['product_test']['measure_ids'].uniq)
      @product.save!
      flash_comment(@product.name, 'success', 'created')
      goto_vendor(@vendor)
    else
      setup_new
      flash_comment(@product.name, 'danger', 'not created because it has no measures specified')
      render :new
    end
  rescue Mongoid::Errors::Validations
    setup_new
    @selected_measure_ids = params['product_test']['measure_ids'] if params['product_test'] && params['product_test']['measure_ids']
    render :new
  end

  def edit
    add_breadcrumb 'Vendor: ' + @product.vendor.name, vendor_path(@product.vendor)
    add_breadcrumb 'Edit Product', :edit_vendor_path
    @selected_measure_ids = @product.measure_ids
  end

  def update
    @product.update_attributes(edit_product_params)
    @product.add_product_tests_to_product(params['product_test']['measure_ids'].uniq) if params['product_test']
    @product.save!
    flash_comment(@product.name, 'info', 'edited')
    goto_vendor(@product.vendor)
  rescue Mongoid::Errors::Validations
    render :edit
  end

  def destroy
    @product.destroy
    flash_comment(@product.name, 'danger', 'removed')
    goto_vendor(@product.vendor)
  end

  # always responds with a pdf file containing information on the certification status of the product
  def report
    pdf = Cypress::PdfReport.new(@product).download_pdf
    send_data(pdf.to_pdf, filename: "Cypress_#{@product.name.underscore.dasherize}_report.pdf", type: 'application/pdf')
  end

  # always responds with a zip file of (.qrda.zip files of (qrda category I documents))
  def patients
    file = Cypress::CreateDownloadZip.create_total_test_zip(@product, 'qrda')
    file_name = "#{@product.name}_#{@product.id}.zip".tr(' ', '_')
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: file_name
  end

  private

  def goto_vendor(vendor)
    respond_to do |f|
      f.json {} # <-- must be fixed later
      f.html { redirect_to vendor_path(vendor.id) }
    end
  end

  def authorize_vendor
    vendor = @vendor || @product.vendor
    authorize_request(vendor, read: ['download_pdf'])
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
    params[:product].permit(:name, :version, :description, :ehr_type, :randomize_records, :duplicate_records, :c1_test, :c2_test, :c3_test, :c4_test,
                            :measure_selection, :bundle_id, product_tests_attributes: [:id, :name, :measure_ids, :_destroy])
  end

  def edit_product_params
    params[:product].permit(:name, :version, :description, :measure_selection, product_tests_attributes: [:id, :name, :measure_ids, :_destroy])
  end
end
