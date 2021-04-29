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
    add_breadcrumb "Vendor: #{@product.vendor_name}", vendor_path(@product.vendor_id)
    add_breadcrumb "Product: #{@product.name}", vendor_product_path(@product.vendor_id, @product)
    @task = Task.find(params[:task_id]) if params[:task_id]
    @has_eh_tests = @product.eh_tests?
    @has_ep_tests = @product.ep_tests?
    respond_with(@product, &:js)
  end

  def new
    @product = Product.new(vendor: @vendor)
    setup_new
  end

  def create
    @product = @vendor.products.new
    @product.update_with_tests(product_params)
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
    add_breadcrumb "Vendor: #{@product.vendor_name}", vendor_path(@product.vendor_id)
    add_breadcrumb "Product: #{@product.name}", vendor_product_path(@product.vendor_id, @product)
    add_breadcrumb 'Edit Product', :edit_vendor_path
    @selected_measure_ids = @product.measure_ids
  end

  def update
    @product.update_with_tests(product_params)
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
    file = if @product.cvuplus
             Cypress::CreateDownloadZip.create_combined_report_zip(@product, report_content: report_content, report_hash: program_report_files)
           else
             Cypress::CreateDownloadZip.create_combined_report_zip(@product, report_content: report_content)
           end
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "#{@product.name}_#{@product.id}_report.zip".tr(' ', '_')
  end

  def program_report_files
    report_hash = {}
    header = "<head>
      <style type=\"text/css\">
        #{Rails.application.assets_manifest.find_sources('application.css').first.to_s.html_safe}
        .exportcircle {
          width: 32px;
          height: 32px;
          border-radius: 50%;
          background: #527E73;
        }
        .exportcircle-empty {
          background: white;
          border: 1px solid #527E73;
        }
      </style>
    </head>"

    @product.product_tests.each do |pt|
      next unless pt.is_a?(CMSProgramTest)

      report_hash[pt.name] = {}
      pt.tasks.each do |t|
        most_recent_execution = t.most_recent_execution
        next unless most_recent_execution

        # TODO: make sure report isn't available for download until individual results are available
        individual_results = CQM::IndividualResult.where(
          correlation_id: most_recent_execution.id
        ).only(:IPP, :DENOM, :NUMER, :NUMEX, :DENEX, :DENEXCEP, :MSRPOPL, :OBSERV, :MSRPOPLEX, :measure_id, :patient_id, :file_name, :population_set_key, :episode_results).to_a
        uploaded_patients = Patient.where(correlation_id: most_recent_execution.id)
        file_name_id_hash = {}
        uploaded_patients.each do |uploaded_patient|
          file_name_id_hash[uploaded_patient['file_name']] = uploaded_patient if uploaded_patient['file_name']
        end
        individual_results.each do |ir|
          next unless ir['file_name']
          next if file_name_id_hash[ir['file_name']]

          file_name_id_hash[ir['file_name']] = ir.patient
        end

        continuous_measures = t.measures.where(measure_scoring: 'CONTINUOUS_VARIABLE').only(:id, :population_sets, :cms_id, :description, :calculation_method).sort_by { |m| [m.cms_int] }
        proportion_measures = t.measures.where(measure_scoring: 'PROPORTION').only(:id, :population_sets, :cms_id, :description, :calculation_method).sort_by { |m| [m.cms_int] }
        ratio_measures = t.measures.where(measure_scoring: 'RATIO').only(:id, :population_sets, :cms_id, :description, :calculation_method).sort_by { |m| [m.cms_int] }
        @task = t
        @individual_results = individual_results
        errors = Cypress::ErrorCollector.collected_errors(most_recent_execution, include_locations: false).files
        file_name_id_hash.each_key do |file_name|
          error_result = errors[file_name]
          patient = file_name_id_hash[file_name]
          next unless patient

          html = if error_result
                   render_to_string partial: 'test_executions/results/execution_results_for_file', locals: {
                     execution: most_recent_execution,
                     file_name: file_name,
                     error_result: error_result,
                     is_passing: most_recent_execution.status_with_sibling == 'passing',
                     on_execution_show_page: true,
                     continuous_measures: continuous_measures,
                     proportion_measures: proportion_measures,
                     ratio_measures: ratio_measures,
                     patient: patient,
                     export: true,
                     display_calculations: true
                   }

                 else
                   render_to_string partial: 'test_executions/results/calculation_results_for_file', locals: {
                     execution: most_recent_execution,
                     file_name: file_name,
                     error_result: error_result,
                     is_passing: most_recent_execution.status_with_sibling == 'passing',
                     on_execution_show_page: true,
                     continuous_measures: continuous_measures,
                     proportion_measures: proportion_measures,
                     ratio_measures: ratio_measures,
                     patient: patient,
                     export: true,
                     display_calculations: true
                   }
                 end
          # note assumes 1 task per CMPSProgramTest producttest
          report_hash[pt.name][file_name] = header + html
        end
      end
    end

    report_hash
  end

  def supplemental_test_artifact
    if @product.supplemental_test_artifact.file.nil?
      redirect_back(fallback_location: root_path, alert: 'Supplement Test Artifact does not exist for this product') && return
    end

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
    @measures = @bundle ? @bundle.measures.only(:cms_id, :description, :title, :category, :hqmf_id, :reporting_program_type) : []
    @measures_categories = @measures.group_by(&:category)
  end

  def setup_new
    add_breadcrumb "Vendor: #{@vendor.name}", vendor_path(@product.vendor_id)
    add_breadcrumb 'Add Product', :new_vendor_path
    set_measures
    params[:action] = 'new'
  end

  def product_params
    params[:product][:name]&.strip!
    params.require(:product).permit(:name, :version, :description, :randomize_patients, :duplicate_patients, :shift_patients, :cures_update,
                                    :bundle_id, :measure_selection, :c1_test, :c2_test, :c3_test, :c4_test, :cvuplus, :vendor_patients,
                                    :bundle_patients, :supplemental_test_artifact, :remove_supplemental_test_artifact, measure_ids: [])
  end

  def edit_product_params
    params[:product][:name]&.strip!
    params.require(:product).permit(:name, :version, :description, :measure_selection, :supplemental_test_artifact,
                                    :remove_supplemental_test_artifact, measure_ids: [])
  end
end
