class ChecklistTestsController < ProductTestsController
  include HealthDataStandards::Export::Helper::ScoopedViewHelper

  before_action :set_product, only: [:create, :show, :update, :destroy]
  before_action :set_test, only: [:show, :update, :destroy]
  before_action :set_measures, only: [:show]

  def create
    # bundle ATTRIBUTE IS NOT CHOSEN CORRECTLY. MUST FIX LATER ~ JAEBIRD
    @test = @product.product_tests.build({ name: 'c1 visual', measure_ids: interesting_measure_ids,
                                           bundle_id: @product.product_tests.measure_tests.first.bundle_id }, ChecklistTest)
    @test.save!
    @test.create_checked_criteria
    redirect_to vendor_product_path(@product.vendor, @product, anchor: 'ChecklistTest')
  end

  def show
    add_breadcrumb 'Vendor: ' + @product.vendor.name, vendor_path(@product.vendor)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor, @product)
    add_breadcrumb 'Test: ' + @test.name, product_checklist_test_path(@product, @test)
  end

  def update
    @test.update_attributes(checklist_test_params)
    @test.save!
    respond_to do |format|
      format.html { redirect_to product_checklist_test_path(@product, @test) }
    end
  rescue Mongoid::Errors::Validations
    render :show
  end

  def destroy
    @test.destroy
    respond_to do |format|
      format.html { redirect_to vendor_product_path(@product.vendor, @product) }
    end
  end

  private

  def authorize_vendor
    set_product
    vendor = @product ? @product.vendor : @product_test.product.vendor
    authorize! :manage, vendor if params[:action] != :show
    authorize! :read, vendor if params[:action] == :show
  end

  def set_test
    @test = @product.product_tests.checklist_tests.first
  end

  def set_measures
    @measures = Measure.top_level.where(:hqmf_id.in => @test.measure_ids)
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
