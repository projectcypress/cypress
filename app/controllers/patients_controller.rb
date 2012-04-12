require 'measure_evaluator'

class PatientsController < ApplicationController

  require 'builder'
  require 'patient_zipper'
  require 'remove_duplicate_patients'
  
  before_filter :authenticate_user!

  def index

    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
      @product = @test.product
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
      @vendor  = @product.vendor
    end

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
    @showAll = true
    if params[:product_test_id]
      @test = ProductTest.find(params[:product_test_id])
    end

    @patients = Result.where("value.test_id" => !@test.nil? ? @test.id : nil).where("value.population" => true)
      .order_by([["value.last", :asc]])
    @patients = Cypress::DuplicateRemover.remove_duplicates(@patients)

    render 'table'
  end

  # Save and serve up the Records associated with this ProductTest. Filetype is specified by :format, patient to download by :id
  # If no patient id is specified, we're downloading the entire Master Patient List  
  def download
    if params[:id]
      patients = Record.where("_id" => params[:id])
    else
      patients = Record.where("test_id" => nil)
    end
    
    file = Tempfile.new("patients-#{Time.now.to_i}")
    format = params[:format]
    
    if format == 'csv'
      Cypress::PatientZipper.flat_file(file, patients)
      send_file file.path, :type => 'text/csv', :disposition => 'attachment', :filename => "'patients_csv.csv"
    else
      Cypress::PatientZipper.zip(file, patients, format.to_sym)
      send_file file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "patients_#{format}.zip"
    end
    
    file.close
  end

end
