class ProgramTestsController < ProductTestsController
  respond_to :js, only: [:show]

  def show
    @product = @product_test.product
    set_breadcrumbs
    @task = Task.find(params[:task_id]) if params[:task_id]
    respond_with(@product, @product_test, &:js)
  end

  def update
    @product = @product_test.product
    @product_test.update_with_program_tests(program_test_params)
    respond_to do |format|
      format.html { redirect_to product_program_test_path(@product, @product_test) }
    end
  rescue Mongoid::Errors::Validations
    @product = @product_test.product
    set_measures
    set_breadcrumbs
    render :show
  end

  def set_breadcrumbs
    add_breadcrumb 'Dashboard', :vendors_path
    add_breadcrumb 'Vendor: ' + @product.vendor_name, vendor_path(@product.vendor_id)
    add_breadcrumb 'Product: ' + @product.name, vendor_product_path(@product.vendor_id, @product)
    add_breadcrumb 'Program Test', product_program_test_path(@product, @product_test)
  end

  def program_test_params
    params[:product_test].permit(program_criteria_attributes: %i[id entered_value])
  end
end
