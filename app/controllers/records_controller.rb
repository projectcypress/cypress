class RecordsController < ApplicationController
  before_action :set_record_source, only: [:index, :show, :by_measure]

  def index
    unless Bundle.default
      @records = []
      @measures = []
      add_breadcrumb 'Master Patient List', :records

      return
    end

    return redirect_to bundle_records_path(Bundle.default) unless params[:bundle_id] || params[:task_id]
    # TODO: Only show measures where there are patient results. CMS32v4 sub id c and d have no patients, for example.
    @records = @source.records.order_by(first: 'asc')
    # create json with the display_name and url for each measure
    @measure_dropdown = Rails.cache.fetch("#{@source.cache_key}/measure_dropdown") do
      @source.measures
             .order_by(cms_int: 1, sub_id: 1)
             .map do |m|
        { label: m.display_name,
          value: by_measure_bundle_records_path(@bundle, measure_id: m.hqmf_id, sub_id: m.sub_id) }
      end.to_json.html_safe
    end
  end

  def show
    @record = @source.records.find(params[:id])
    @results = @record.calculation_results
    @measures = @source.measures.where(:hqmf_id.in => @results.map(:value).map(&:measure_id)).where(:sub_id.in => @results.map(:value).map(&:sub_id))
    expires_in 1.week, public: true
    add_breadcrumb 'Patient: ' + @record.first + ' ' + @record.last, :record_path
  end

  def by_measure
    @records = @source.records
    if params[:measure_id]
      @measure = @source.measures.find_by(hqmf_id: params[:measure_id], sub_id: params[:sub_id])
      expires_in 1.week, public: true
    end
  end

  def download_mpl
    if BSON::ObjectId.legal?(params[:format])
      bundle = Bundle.find(BSON::ObjectId.from_string(params[:format]))

      unless File.exist?(bundle.mpl_path)
        MplDownloadCreateJob.perform_now(bundle.id.to_s)
      end

      file = File.new(bundle.mpl_path)
      expires_in 1.month, public: true
      send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "bundle_#{bundle.version}_mpl.zip"
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
    @source = @bundle = Bundle.find(params[:bundle_id])
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
    add_breadcrumb 'Product: ' + @product_test.product.name, vendor_product_path(@product_test.product.vendor, @product_test.product)
    add_breadcrumb 'Test: ' + @product_test.name, new_task_test_execution_path(@task.id)
    add_breadcrumb 'Patient List', records_path(task_id: @task.id)
  end
end
