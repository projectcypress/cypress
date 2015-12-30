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
    create_checked_criteria
    redirect_to "/vendors/#{@product.vendor.id}/products/#{@product.id}#ChecklistTest"
  end

  def show
    add_breadcrumb 'Vendor: ' + @product.vendor.name, "/vendors/#{@product.vendor.id}"
    add_breadcrumb 'Product: ' + @product.name, "/vendors/#{@product.vendor.id}/products/#{@product.id}"
    add_breadcrumb 'Test: ' + @test.name, "/products/#{@product.id}/checklist_tests/#{@test.id}"
  end

  def update
    @test.update_attributes(checklist_test_params)
    @test.save!
    respond_to do |format|
      format.html { redirect_to "/products/#{@product.id}/checklist_tests/#{@test.id}" }
    end
  rescue Mongoid::Errors::Validations
    render :show
  end

  def destroy
    @test.destroy
    respond_to do |format|
      format.html { redirect_to "/vendors/#{@product.vendor.id}/products/#{@product.id}" }
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_test
    @test = @product.product_tests.checklist_tests.first
  end

  def set_measures
    @measures = Measure.top_level.where(:hqmf_id.in => @test.measure_ids)
  end

  # CHOOSE INTERESTING CRITERIA HERE - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
  def interesting_measure_ids
    @product.product_tests.measure_tests.map { |test| test.measure_ids.first }.sample(5) # Probably not the way we want to choose measures ~ Jaebird
  end

  # CHOOSE INTERESTING CRITERIA HERE - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
  def create_checked_criteria
    checked_criterias = []
    measures = Measure.top_level.where(:hqmf_id.in => @test.measure_ids)
    measures.each do |measure|
      criterias = measure['hqmf_document']['source_data_criteria'].sort_by { rand }.first(5) # Probably not the way we want to choose criteria ~ Jesse
      criterias.each do |criteria_key, _criteria_value|
        checked_criterias.push(measure_id: measure.id.to_s, source_data_criteria: criteria_key, completed: false)
      end
    end
    @test.checked_criteria = checked_criterias
    @test.save!
  end

  def checklist_test_params
    params[:product_test].permit(checked_criteria_attributes: [:id, :_destroy, :completed])
  end
end
