class ChecklistTestsController < ProductTestsController
  before_action :set_measures, only: [:show]
  before_action :set_measure, only: [:measure]
  before_action :check_bundle_deprecated, only: [:show]
  respond_to :js, only: [:show]

  def create
    @product_test = @product.product_tests.build({ name: 'c1 visual', measure_ids: @product.measure_ids }, ChecklistTest)
    @product_test.save!
    @product_test.create_checked_criteria
    C1ChecklistTask.new(product_test: @product_test).save!
    redirect_to vendor_product_path(@product.vendor_id, @product, anchor: 'ChecklistTest')
  end

  def show
    @product = @product_test.product
    set_breadcrumbs
    @task = Task.find(params[:task_id]) if params[:task_id]
    respond_with(@product, @product_test, &:js)
  end

  def update
    @product = @product_test.product
    @product_test.update_with_checklist_tests(checklist_test_params)
    respond_to do |format|
      format.html { redirect_to product_checklist_test_path(@product, @product_test) }
    end
  rescue Mongoid::Errors::Validations
    @product = @product_test.product
    set_measures
    set_breadcrumbs
    render :show
  end

  def destroy
    @product_test.destroy
    respond_to do |format|
      format.html { redirect_to vendor_product_path(@product.vendor_id, @product) }
    end
  end

  def measure
    @product = @product_test.product
    @measures = @product_test.measures
    set_breadcrumbs
    add_breadcrumb "Measure: #{@measure.cms_id}", measure_checklist_test_path(@product_test, @measure)
  end

  def print_criteria
    criteria_list = render_to_string layout: 'report'
    checklist_test = @product.product_tests.checklist_tests.first
    zip = Cypress::CreateDownloadZip.create_c1_criteria_zip(checklist_test, criteria_list).read
    filename = "#{@product.name}_#{@product.id}_c1_checklist_criteria.zip".tr(' ', '_')
    send_data zip, type: 'application/zip', disposition: 'attachment', filename: filename
  end

  private

  def set_breadcrumbs
    add_breadcrumb 'Dashboard', :vendors_path
    add_breadcrumb 'Vendor: ' + @product.vendor_name, vendor_path(@product.vendor_id)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor_id, @product)
    add_breadcrumb 'Record Sample', product_checklist_test_path(@product, @product_test)
  end

  def set_measures
    @measures = @product_test.measures.sort_by(&:cms_int)
  end

  def set_measure
    @measure = Measure.find_by(_id: params[:measure_id])
  end

  def checklist_test_params
    params[:product_test].permit(checked_criteria_attributes: %i[id
                                                                 _destroy
                                                                 code
                                                                 attribute_code
                                                                 recorded_result
                                                                 negated_valueset
                                                                 selected_negated_valueset
                                                                 replacement_data_criteria])
  end
end
