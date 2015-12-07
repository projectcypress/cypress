class ProductsController < ApplicationController
  before_action :set_vendor, only: [:new, :create, :index]
  before_action :set_product, except: [:index, :new, :create]
  before_action :set_measures, only: [:new, :update]

  def index
    respond_to do |f|
      f.html { redirect_to vendor_path(@vendor.id) }
    end
  end

  def new
    @product = Product.new
    @product.vendor = @vendor
    setup_new
    respond_to do |format|
      format.html
      format.json { render json: { measures: @measures, measures_categories: @measures_categories, product: @product } }
    end
  end

  def create
    @product = Product.new(product_params)
    @product.vendor = @vendor
    @product.add_product_tests_to_product(params['product_test']['measure_ids'].uniq) if params['product_test']
    @product.save!
    flash_product_comment(@product.name, 'success', 'created')
    respond_to do |f|
      f.json {} # <-- must be fixed later
      f.html { redirect_to vendor_path(@vendor.id) }
    end
  rescue Mongoid::Errors::Validations
    setup_new
    @selected_measure_ids = params['product_test']['measure_ids'] if params['product_test'] && params['product_test']['measure_ids']
    render :new
  end

  def edit
    add_breadcrumb @product.vendor.name, "/vendors/#{@product.vendor.id}"
    add_breadcrumb 'Edit Product', :edit_vendor_path
    set_measures
    @selected_measure_ids = @product.measure_ids
  end

  def update
    @product.update_attributes(edit_product_params)
    @product.add_product_tests_to_product(params['product_test']['measure_ids'].uniq) if params['product_test']
    @product.save!
    flash_product_comment(@product.name, 'info', 'edited')
    respond_to do |f|
      f.json {} # <-- must be fixed later
      f.html { redirect_to vendor_path(@product.vendor.id) }
    end
  rescue Mongoid::Errors::Validations
    render :edit
  end

  def destroy
    @product.destroy
    flash_product_comment(@product.name, 'danger', 'removed')
    respond_to do |format|
      format.json {} # <-- must be fixed later
      format.html { redirect_to vendor_path(@product.vendor.id) }
    end
  end

  def show
    add_breadcrumb @product.vendor.name, "/vendors/#{@product.vendor.id}"
    add_breadcrumb @product.name, "/vendors/#{@product.vendor.id}/products/#{@product.id}"
    respond_to do |format|
      format.json { render json: [@product] }
      format.html
    end
  end

  def download_total_test_deck
    file = Cypress::CreateDownloadZip.create_total_test_zip(@product)
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "Full_Test_Deck_#{params[:id]}.zip"
  end

  private

  def set_product
    product_finder = @vendor ? @vendor.products : Product
    @product = product_finder.find(params[:id])
  end

  def set_measures
    # TODO: Get latest version of each measure
    @measures = Measure.top_level
    @measures.sort_by! { |m| m.cms_id[3, m.cms_id.index('v') - 3].to_i } if @measures.all? { |m| !m.cms_id.nil? }
    @measures_categories = @measures.group_by(&:category)
  end

  def set_vendor
    @vendor ||= Vendor.find(params[:vendor_id])
  end

  def setup_new
    add_breadcrumb @vendor.name, "/vendors/#{@vendor.id}"
    add_breadcrumb 'Add Product', :new_vendor_path
    set_measures
    params[:action] = 'new'
  end

  def product_params
    params[:product].permit(:name, :version, :description, :ehr_type, :c1_test, :c2_test, :c3_test, :c4_test, :measure_selection,
                            product_tests_attributes: [:id, :name, :measure_ids, :bundle_id, :_destroy])
  end

  def edit_product_params
    params[:product].permit(:name, :version, :description,
                            product_tests_attributes: [:id, :name, :measure_ids, :bundle_id, :_destroy])
  end

  def flash_product_comment(product_name, notice_type, action_type)
    flash[:notice] = "Product '#{product_name}' was #{action_type}."
    flash[:notice_type] = notice_type
  end
end
