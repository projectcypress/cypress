class ProductsController < ApplicationController
  include API::Controller
  before_action :set_vendor, only: %i[index new create report patients favorite]
  before_action :set_product, except: %i[index new create]
  before_action :set_measures, only: %i[new edit update report]
  before_action :authorize_vendor
  before_action :require_admin_atl, only: %i[report supplemental_test_artifact]
  before_action :check_bundle_deprecated, only: %i[show edit]
  add_breadcrumb 'Dashboard', :vendors_path

  respond_to :html, except: [:index]
  respond_to :json, :xml, except: %i[new edit update]
  respond_to :js, only: [:favorite]

  def index
    @products = @vendor.products.sort_by { |a| a.favorite_user_ids.include? current_user.id ? 0 : 1 }
    respond_with(@products.to_a)
  end

  def show
    add_breadcrumb 'Vendor: ' + @product.vendor_name, vendor_path(@product.vendor_id)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor_id, @product)
    @task = Task.find(params[:task_id]) if params[:task_id]
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
    add_breadcrumb 'Vendor: ' + @product.vendor_name, vendor_path(@product.vendor_id)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor_id, @product)
    add_breadcrumb 'Edit Product', :edit_vendor_path
    @selected_measure_ids = @product.measure_ids
  end

  def update
    @product.update_with_measure_tests(edit_product_params)
    @product.save!
    flash_comment(@product.name, 'info', 'edited')
    respond_with(@product) do |f|
      f.html { redirect_to vendor_path(@product.vendor_id) }
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
    respond_with(@product) { |f| f.html { redirect_to vendor_path(@product.vendor_id) } }
  end

  # always responds with a zip file containing information on the certification status of the product
  # includes an html report plus all the test records and files
  def report
    report_content = render_to_string layout: 'report'
    file = Cypress::CreateDownloadZip.create_combined_report_zip(@product, report_content)
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "#{@product.name}_#{@product.id}_report.zip".tr(' ', '_')
  end

  def supplemental_test_artifact
    redirect_to(:back, alert: 'Supplement Test Artifact does not exist for this product') && return if @product.supplemental_test_artifact.file.nil?
    send_file @product.supplemental_test_artifact.file.path, disposition: 'attachment'
  end

  # always responds with a zip file of (.qrda.zip files of (qrda category I documents))
  def patients
    crit_exists = !@product.product_tests.checklist_tests.empty?
    filt_exists = !@product.product_tests.filtering_tests.empty?
    criteria_list = crit_exists ? render_to_string(file: 'checklist_tests/print_criteria.html.erb', layout: 'report') : nil
    filtering_list = filt_exists ? render_to_string(file: 'checklist_tests/print_filtering.html.erb', layout: 'report') : nil
    file = Cypress::CreateTotalTestZip.create_total_test_zip(@product, criteria_list, filtering_list, 'qrda')
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "#{@product.name}_#{@product.id}.zip".tr(' ', '_')
  end

  def favorite
    deleted_value = @product.favorite_user_ids.delete(current_user.id)
    @product.favorite_user_ids.push(current_user.id) if deleted_value.nil?
    @product.save!
    respond_with(@product)
  end

  private

  def authorize_vendor
    vendor = @vendor || @product.vendor
    authorize_request(vendor, read: %w[report patients])
  end

  def set_measures
    @bundle = @product&.bundle ? @product.bundle : Bundle.default
    @measures = @bundle ? @bundle.measures.top_level.only(:cms_id, :sub_id, :name, :category, :hqmf_id, :type) : []
    @measures_categories = @measures.group_by(&:category)
  end

  def setup_new
    add_breadcrumb 'Vendor: ' + @vendor.name, vendor_path(@product.vendor_id)
    add_breadcrumb 'Add Product', :new_vendor_path
    set_measures
    params[:action] = 'new'
  end

  def product_params
    params[:product][:name]&.strip!
    params.require(:product).permit(:name, :version, :description, :randomize_patients, :duplicate_patients, :shift_patients,
                                    :bundle_id, :measure_selection, :cert_edition, :c1_test, :c2_test, :c3_test, :c4_test,
                                    :supplemental_test_artifact, :remove_supplemental_test_artifact, measure_ids: [])
  end

  def edit_product_params
    params[:product][:name]&.strip!
    params.require(:product).permit(:name, :version, :description, :measure_selection, :supplemental_test_artifact,
                                    :remove_supplemental_test_artifact, measure_ids: [])
  end
end
