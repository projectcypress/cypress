class ChecklistTestsController < ProductTestsController
  include HealthDataStandards::Export::Helper::ScoopedViewHelper

  before_action :set_measures, only: [:show]

  def create
    @product_test = @product.product_tests.build({ name: 'c1 visual', measure_ids: interesting_measure_ids }, ChecklistTest)
    @product_test.save!
    @product_test.create_checked_criteria
    redirect_to vendor_product_path(@product.vendor, @product, anchor: 'ChecklistTest')
  end

  def show
    @product = @product_test.product
    add_breadcrumb 'Vendor: ' + @product.vendor.name, vendor_path(@product.vendor)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor, @product)
    add_breadcrumb 'Test: ' + @product_test.name, product_checklist_test_path(@product, @product_test)
  end

  def update
    @product_test.update_attributes(checklist_test_params)
    @product_test.save!
    respond_to do |format|
      format.html { redirect_to product_checklist_test_path(@product, @product_test) }
    end
  rescue Mongoid::Errors::Validations
    render :show
  end

  def destroy
    @product_test.destroy
    respond_to do |format|
      format.html { redirect_to vendor_product_path(@product.vendor, @product) }
    end
  end

  private

  def authorize_vendor
    set_product
    vendor = @product ? @product.vendor : @product_test.product.vendor
    authorize_request(vendor)
  end

  def set_test
    @product_test = @product.product_tests.checklist_tests.first
  end

  def set_measures
    @measures = @product_test.measures.top_level.sort_by(&:cms_int)
  end

  # CHOOSE INTERESTING CRITERIA HERE - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
  def interesting_measure_ids
    @product.product_tests.measure_tests.map { |test| test.measure_ids.first } # Probably not the way we want to choose measures ~ Jaebird
  end

  # CHOOSE INTERESTING CRITERIA HERE - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

  def checklist_test_params
    params[:product_test].permit(checked_criteria_attributes: [:id, :_destroy, :completed])
  end
end
