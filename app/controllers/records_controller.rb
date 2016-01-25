class RecordsController < ApplicationController
  before_action :set_record_source, only: [:index, :show, :by_measure]
  add_breadcrumb 'Master Patient List', :records_path

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
    elsif params[:product_test_id]
      @product_test = ProductTest.find(params[:product_test_id])
      @source = @product_test
    elsif params[:task_id]
      @task = Task.find(params[:task_id])
      @source = @task
    else
      @bundle = Bundle.first
      @source = @bundle
    end
  end
end
