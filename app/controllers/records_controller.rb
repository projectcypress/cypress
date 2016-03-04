class RecordsController < ApplicationController
  before_action :set_record_source, only: [:index, :show, :by_measure]

  def download_full_test_deck
    product = Product.find(params[:id])
    file = Cypress::CreateDownloadZip.create_total_test_zip(product, 'qrda')
    file_name = "#{product.name}_#{product.id}.zip".tr(' ', '_')
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: file_name
  end

  def index
    # TODO: Only show measures where there are patient results. CMS32v4 sub id c and d have no patients, for example.
    @records = @source.records
    @measures = @source.measures.sort_by! { |m| [m.cms_int, m.sub_id] }
  end

  def show
    @record = @source.records.find(params[:id])
    @results = @record.calculation_results
    @measures = @source.measures.where(:hqmf_id.in => @results.map(:value).map(&:measure_id)).where(:sub_id.in => @results.map(:value).map(&:sub_id))
    add_breadcrumb 'Patient: ' + @record.first + ' ' + @record.last, :record_path
  end

  def by_measure
    @records = @source.records
    if params[:measure_id]
      @measure = @source.measures.find_by(hqmf_id: params[:measure_id], sub_id: params[:sub_id])
    end
  end

  private

  def set_record_source
    if params[:bundle_id]
      @bundle = Bundle.find(params[:bundle_id])
      @source = @bundle
      add_breadcrumb 'Master Patient List', :records_path
    elsif params[:task_id]
      @task = Task.find(params[:task_id])
      @product_test = @task.product_test
      @measure = Measure.where(hqmf_id: @product_test.measure_ids.first).first
      @source = @product_test
      add_breadcrumb 'Test: ' + @product_test.name, new_task_test_execution_path(task_id: @task.id)
      add_breadcrumb 'Patient List', records_path(task_id: @task.id)
    else
      @bundle = Bundle.where(active: true).first
      @source = @bundle
      add_breadcrumb 'Master Patient List', :records_path
    end
  end
end
