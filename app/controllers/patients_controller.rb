
class PatientsController < ApplicationController

  require 'builder'

  
  before_filter :authenticate_user!

  def index

    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
      @product = @test.product
      @product.measure_map ||= Measure.default_map
      @vendor  = @product.vendor
      @measures = @test.measure_defs
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
      @result = {'measure_id' => '-', 'numerator' => '-', 'antinumerator' => '-', 'denominator' => '-', 'exclusions' => '-'}
    else
      if params[:product_test_id]
        if @measures.include?(@selected)
          @result = Cypress::MeasureEvaluator.eval(@test, @selected)
        else
          # If the selected measure wasn't chosen to be part of the test, return zeroed results
          @result = {'measure_id' => @selected.id, 'numerator' => '0', 'antinumerator' => 0, 'denominator' => '0', 'exclusions' => '0'}
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
      @product.measure_map ||= Measure.default_map
      @vendor  = @product.vendor
    end
    @effective_date = Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE

    @results = Result.all(:conditions => {'value.patient_id' => @patient.id}, :sort => [['value.measure_id', :asc], ['value.sub_id', :asc]])
  end

  def table_measure
    @showAll = false
    @measures = Measure.installed
    @measures_categories = @measures.group_by { |t| t.category }
    @selected = Measure.find(params[:measure_id])

    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
    end

    @patients = Result.where("value.test_id" => !@test.nil? ? @test.id : nil).where("value.measure_id" => @selected['id'])
      .where("value.sub_id" => @selected.sub_id).where("value.population" => true)
      .order_by([ ["value.numerator", :desc], ["value.denominator", :desc], ["value.exclusions", :desc]])

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
