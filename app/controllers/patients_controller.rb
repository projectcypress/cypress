
class PatientsController < ApplicationController

  require 'builder'

  
  before_filter :authenticate_user!

  def index

    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
      @product = @test.product
      @vendor  = @product.vendor
      @measures = @test.measures
    else
      @measures = Measure.installed
    end
    @measures_categories = @measures.group_by { |t| t.category }
    
    @showAll = false
    if params[:measure_id]
      @selected = Measure.find(params[:measure_id])
    else
      @selected = @measures[0]
      @showAll = true
    end
    
    # If a ProductTest is specified, show results for only the patients included in that population
    # Otherwise show the whole Master Patient List
    if @showAll
      @result = {'measure_id' => '-', 'NUMER' => '-', 'antinumerator' => '-', 'DENOM' => '-', 'DENEX' => '-'}
    else
      if params[:product_test_id]
        if @measures.include?(@selected)
          @result = Cypress::MeasureEvaluator.eval(@test, @selected)
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
    end
    @effective_date = Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE

    @results = Result.where({'value.medical_record_id' => @patient.medical_record_number}).order_by([['value.measure_id', :asc], ['value.sub_id', :asc]])
  end

  def table_measure

    @showAll = false
    @measures = Measure.installed
    @measures_categories = @measures.group_by { |t| t.category }
    @selected = Measure.find(params[:measure_id])

    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
    end

   
    @patients = Result.where("value.test_id" => !@test.nil? ? @test.id : nil).where("value.measure_id" => @selected.hqmf_id)
      .where("value.sub_id" => @selected.sub_id).where("value.IPP".to_sym.gt => 0)
      .order_by([ ["value.NUMER", :desc], ["value.DENOM", :desc], ["value.DENEX", :desc]])

    render 'table'
  end

  def table_all
    
    @showAll  = true
    @patients = nil
    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
      @patients = Record.where("test_id" => @test.id).order_by([["last", :asc]])
    else
      @patients = Record.where("test_id" => nil).order_by([["last", :asc]])
    end

    render 'table'
  end

  #send user record associated with patient
  def download
    file = Cypress::CreateDownloadZip.create_patient_zip(params[:id],params[:format])
    if params[:format] == 'csv'
      send_file file.path, :type => 'text/csv', :disposition => 'attachment', :filename => "'patient_#{params[:id]}.csv"
    else
      send_file file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "patient_#{params[:id]}_#{params[:format]}.zip"
    end
    file.close
  end

end
