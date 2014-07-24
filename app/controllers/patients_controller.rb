
class PatientsController < ApplicationController

  require 'builder'

  before_filter :authenticate_user!
  before_filter :find_bundle_or_active

  def index
    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
      @product = @test.product
      @vendor  = @product.vendor
      @measures = @test.measures
    else
      #@measures = Rails.cache.fetch("bundle_measures_" + @bundle.version) { @bundle.measures }
      @measures = @bundle.measures
    end
    #only get the measures_categories if we don't have a fragment for the view section
    if !fragment_exist?("index-" + @bundle.version)
      @measures_categories = @measures.group_by { |t| t.category }
    end

    @showAll = false
    if params[:measure_id]
      @selected = Measure.where(_id: params[:measure_id]).first
    else
      @selected = Rails.cache.fetch("measures_0_bundle_ver_" + @bundle.version ) { @measures[0] }
      @showAll = true
    end

    # If a ProductTest is specified, show results for only the patients included in that population
    # Otherwise show the whole Master Patient List
    if @showAll
      @result = {'measure_id' => '-', 'NUMER' => '-', 'antinumerator' => '-', 'DENOM' => '-', 'DENEX' => '-'}
    else
      if params[:product_test_id]
        if @measures.include?(@selected)
          @result = @test.expected_result(@selected)
        else
          # If the selected measure wasn't chosen to be part of the test, return zeroed results
          @result = {'measure_id' => @selected.id, 'NUMER' => '0', 'antinumerator' => 0, 'DENOM' => '0', 'DENEX' => '0'}
        end
      else
        @result = Cypress::MeasureEvaluator.eval_for_static_records(@selected)
      end
    end

    respond_to do |format|
      format.json { render :json => @result }
      format.html
    end
  end

  def show

    @patient = Record.find(params[:id])
    if @patient.test_id
      @test = ProductTest.find(@patient.test_id)
      @product = @test.product
      @vendor  = @product.vendor
      @effective_date = @test.effective_date
    else
      @effective_date = @patient.bundle.effective_date
    end

    if @test
      @results =Result.where({ "value.test_id" => @test.id, 'value.medical_record_id' => @patient.medical_record_number}).order_by([['value.nqf_id', :asc], ['value.sub_id', :asc]])
    else
       @results = @patient.bundle.results.where({'value.medical_record_id' => @patient.medical_record_number}).order_by([['value.nqf_id', :asc], ['value.sub_id', :asc]])
    end
  end

  def table_measure
    @selected = Measure.where(_id: params[:measure_id]).first
    @bundle = Bundle.find(@selected.bundle_id)
    @showAll = false
    @measures = @bundle.measures
    @measures_categories = @measures.group_by { |t| t.category }


    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
      @patients = @test.results.where("value.measure_id" => @selected.hqmf_id).where("value.sub_id" => @selected.sub_id).where("value.IPP".to_sym.gt => 0).order_by([ ["value.NUMER", :desc], ["value.DENOM", :desc], ["value.DENEX", :desc]])
    else
    @patients = @bundle.results.where("value.measure_id" => @selected.hqmf_id)
      .where("value.sub_id" => @selected.sub_id).where("value.IPP".to_sym.gt => 0)
      .order_by([ ["value.NUMER", :desc], ["value.DENOM", :desc], ["value.DENEX", :desc]])
    end
    render 'table'
  end

  def table_all

    @showAll  = true
    @patients = nil
    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
      @patients = @test.records.order_by([["last", :asc]])
    else
      @patients = @bundle.records.order_by([["last", :asc]])
    end

    render 'table'
  end

  #send user record associated with patient
  def download
    data = cache(id: params[:id],format: params[:format],bundle_id:  params[:bundle_id]) do
      file = nil
      if params[:id]
        file = Cypress::CreateDownloadZip.create_patient_zip(Record.find(params[:id]),params[:format])
      else
        file = Cypress::CreateDownloadZip.create_zip(@bundle.records, params[:format])
      end
      file.read
    end

    send_data data, :type => 'application/zip', :disposition => 'attachment', :filename => "patient_#{params[:id]}_#{params[:format]}.zip"
  end

  private

  def find_bundle_or_active
    @bundle = params[:bundle_id].nil? ? Bundle.active.first : Bundle.find(params[:bundle_id])
  end
end
