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

    return redirect_to bundle_records_path(Bundle.default) unless params[:bundle_id] || params[:task_id] || params[:vendor_id]

    # create json with the display_name and url for each measure
    @measure_dropdown = measures_for_source
    if @vendor
      @patients = @vendor.patients.where(bundleId: @bundle.id.to_s).order_by(first: 'asc')
    else
      @patients = @source.patients.order_by(first: 'asc')
      @mpl_bundle = Bundle.find(params[:mpl_bundle_id]) if params[:mpl_bundle_id]
    end
  end

  def show
    @record = @source.patients.find(params[:id])
    @results = @record.calculation_results
    @measures = (@vendor ? @bundle : @source).measures.where(:_id.in => @results.map(&:measure_id))
    @hqmf_id = params[:hqmf_id]
    @continuous_measures = @measures.where(measure_scoring: 'CONTINUOUS_VARIABLE').sort_by { |m| [m.cms_int] }
    @proportion_measures = @measures.where(measure_scoring: 'PROPORTION').sort_by { |m| [m.cms_int] }
    expires_in 1.week, public: true
    add_breadcrumb 'Patient: ' + @record.first_names + ' ' + @record.familyName, :record_path
  end

  def by_measure
    @patients = @vendor.patients.includes(:calculation_results).where(bundleId: @bundle.id.to_s) if @vendor
    @patients ||= @source.patients.includes(:calculation_results)

    if params[:measure_id]
      measures = @vendor ? @bundle.measures : @source.measures
      @measure = measures.find_by(hqmf_id: params[:measure_id])
      @population_set_hash = params[:population_set_hash] || @measure.population_sets_and_stratifications_for_measure.first
      expires_in 1.week, public: true
    end
  end

  def by_filter_task
    @patients = Patient.where(:_id.in => @product_test.filtered_patients.map(&:id))
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
      render body: nil, status: :bad_request
    end
  end

  private

  # note: case vendor will also have a bundle id
  def set_record_source
    if params[:vendor_id]
      set_record_source_vendor
    elsif params[:task_id]
      set_record_source_product_test
    else
      set_record_source_bundle
    end
  end

  # sets the record source to bundle for the master patient list
  def set_record_source_bundle
    # TODO: figure out what scenarios lead to no params[:bundle_id] here
    @source = @bundle = params[:bundle_id] ? Bundle.available.find(params[:bundle_id]) : Bundle.default
    return unless @bundle

    add_breadcrumb 'Master Patient List', bundle_records_path(@bundle)
    @title = 'Master Patient List'
  end

  # sets the record source to product_test for the patients for a measure test
  def set_record_source_vendor
    @bundle = params[:bundle_id] ? Bundle.available.find(params[:bundle_id]) : Bundle.default
    @vendor = Vendor.find(params[:vendor_id])
    @source = @vendor
    breadcrumbs_for_vendor_path
    @title = "#{@vendor.name} Uploaded Patients"
  end

  def breadcrumbs_for_vendor_path
    add_breadcrumb 'Dashboard', :vendors_path
    add_breadcrumb 'Vendor: ' + @vendor.name, vendor_path(@vendor)
    add_breadcrumb 'Patient List', vendor_records_path(vendor_id: @vendor.id, bundle_id: @bundle&.id)
  end

  # sets the record source to product_test for the patients for a measure test
  def set_record_source_product_test
    @task = Task.find(params[:task_id])
    @product_test = @task.product_test
    @bundle = @product_test.bundle
    authorize! :read, @product_test.product.vendor
    @measure = @product_test.measures.where(hqmf_id: params['hqmf_id']).first
    @measure ||= @product_test.measures.first
    @population_set_hash = params[:population_set_hash] || @measure.population_sets_and_stratifications_for_measure.first
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

  def measures_for_source
    Rails.cache.fetch("#{@source.cache_key}/measure_dropdown") do
      if @vendor
        @bundle.measures.order_by(cms_int: 1).map do |m|
          { label: "#{m.cms_id}: #{m.description}",
            value: by_measure_vendor_records_path(@vendor, measure_id: m.hqmf_id, bundle_id: @bundle.id) }
        end
      else
        @source.measures.order_by(cms_int: 1).map do |m|
          { label: "#{m.cms_id}: #{m.description}",
            value: by_measure_bundle_records_path(@bundle, measure_id: m.hqmf_id) }
        end
      end.to_json.html_safe
    end
  end
end
