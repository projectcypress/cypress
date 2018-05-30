class RecordsController < ApplicationController
  before_action :set_record_source, only: %i[index show by_measure by_filter_task]

  respond_to :js, only: [:index]

  def index
    unless Bundle.default
      @patients = []
      @measures = []
      add_breadcrumb 'Master Patient List', :records

      return
    end

    return redirect_to bundle_records_path(Bundle.default) unless params[:bundle_id] || params[:task_id]
    # TODO: Only show measures where there are patient results. CMS32v4 sub id c and d have no patients, for example.
    @patients = @source.patients.order_by(first: 'asc')
    # create json with the display_name and url for each measure
    @measure_dropdown = Rails.cache.fetch("#{@source.cache_key}/measure_dropdown") do
      @source.measures
             .order_by(cms_int: 1, sub_id: 1)
             .map do |m|
        { label: m.display_name,
          value: by_measure_bundle_records_path(@bundle, measure_id: m.hqmf_id, sub_id: m.sub_id) }
      end.to_json.html_safe
    end
    @mpl_bundle = Bundle.find(params[:mpl_bundle_id]) if params[:mpl_bundle_id]
  end

  def show
    @record = @source.patients.find(params[:id])
    @results = @record.calculation_results
    @measures = @source.measures.where(:_id.in => @results.map(&:measure_id))
    expires_in 1.week, public: true
    add_breadcrumb 'Patient: ' + @record.first_names + ' ' + @record.familyName, :record_path
  end

  def by_measure
    @records = @source.records
    if params[:measure_id]
      @measure = @source.measures.find_by(hqmf_id: params[:measure_id], sub_id: params[:sub_id])
      expires_in 1.week, public: true
    end
  end

  def by_filter_task
    @records = @product_test.filtered_patients
  end

  def download_mpl
    if BSON::ObjectId.legal?(params[:format])
      bundle = Bundle.find(BSON::ObjectId.from_string(params[:format]))

      if bundle.mpl_status != :ready
        flash[:info] = 'This bundle is currently preparing for download.'
        redirect_to :back
      else
        file = File.new(bundle.mpl_path)
        expires_in 1.month, public: true
        send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "bundle_#{bundle.version}_mpl.zip"
      end
    else
      render nothing: true, status: 400
    end
  end

  private

  def set_record_source
    if params[:bundle_id]
      set_record_source_bundle
    elsif params[:task_id]
      set_record_source_product_test
    else
      # TODO: figure out what scenarios lead to this branch and fix them
      @bundle = Bundle.default
      @source = @bundle
      return unless @bundle
      add_breadcrumb 'Master Patient List', bundle_records_path(@bundle)
      @title = 'Master Patient List'
    end
  end

  # sets the record source to bundle for the master patient list
  def set_record_source_bundle
    @source = @bundle = Bundle.available.find(params[:bundle_id])
    add_breadcrumb 'Master Patient List', bundle_records_path(@bundle)
    @title = 'Master Patient List'
  end

  # sets the record source to product_test for the patients for a measure test
  def set_record_source_product_test
    @task = Task.find(params[:task_id])
    @product_test = @task.product_test
    @bundle = @product_test.bundle
    authorize! :read, @product_test.product.vendor
    @measure = @product_test.measures.where(sub_id: params['sub_id']).first
    @measure ||= @product_test.measures.first
    @source = @product_test
    breadcrumbs_for_test_path
    @title = "#{@task.product_test.product.name} #{@task._type.titleize} #{@task.product_test.measures.first.cms_id} Patients"
  end

  def breadcrumbs_for_test_path
    add_breadcrumb 'Dashboard', :vendors_path
    add_breadcrumb 'Vendor: ' + @product_test.product.vendor.name, vendor_path(@product_test.product.vendor)
    add_breadcrumb 'Product: ' + @product_test.product_name, vendor_product_path(@product_test.product.vendor, @product_test.product)
    add_breadcrumb 'Test: ' + @product_test.name, new_task_test_execution_path(@task.id)
    add_breadcrumb 'Patient List', records_path(task_id: @task.id)
  end
end
