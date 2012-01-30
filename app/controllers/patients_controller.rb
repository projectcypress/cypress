require 'measure_evaluator'

class PatientsController < ApplicationController

  require 'builder'

  before_filter :authenticate_user!

  def index
    @measures = Measure.installed
    @measures_categories = @measures.group_by { |t| t.category }
    
    if params[:vendor_id]
      @vendor = Vendor.find(params[:vendor_id])
    end
    
    if params[:measure_id]
      @selected = Measure.find(params[:measure_id])
    else
      @selected = @measures[0]
    end
    @result = Cypress::MeasureEvaluator.eval_for_static_records(@selected)
    respond_to do |format|
      format.json { render :json => @result }
      format.html
    end
  end

  def table
    @measures = Measure.installed
    @measures_categories = @measures.group_by { |t| t.category }
    if params[:measure_id]
      @selected = Measure.find(params[:measure_id])
    else
      @selected = @measures[0]
    end
    
    if params[:vendor_id]
      @vendor = Vendor.find(params[:vendor_id])
    end
    
    @patients = Result.where("value.test_id" => @vendor ? @vendor.id : nil).where("value.measure_id" => @selected['id'])
      .where("value.sub_id" => @selected.sub_id).where("value.population" => true)
    if params[:search] && params[:search].size>0
      @search_term = params[:search]
      regex = Regexp.new('^'+params[:search], Regexp::IGNORECASE)
      patient_ids = Record.any_of({"first" => regex}, {"last" => regex}).collect {|p| p.id}
      @patients = @patients.any_in("value.patient_id" => patient_ids)
    end
    @patients = @patients.order_by([
      ["value.numerator", :desc], ["value.denominator", :desc], ["value.exclusions", :desc]])
  end

  def zipc32
    t = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => nil)
    Cypress::PatientZipper.zip(t, patients, :c32)
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', 
      :filename => 'patients_c32.zip'
    t.close
  end

  def zipccr
     t = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => nil)
    Cypress::PatientZipper.zip(t, patients, :ccr)
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', 
      :filename => 'patients_ccr.zip'
    t.close
  end
  
  def ziphtml
     t = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => nil)
    Cypress::PatientZipper.zip(t, patients, :html)
    send_file t.path, :type => 'application/zip', :disposition => 'attachment', 
      :filename => 'patients_html.zip'
    t.close
  end
  
   def csv
     t = Tempfile.new("patients-#{Time.now.to_i}")
    patients = Record.where("test_id" => nil)
    Cypress::PatientZipper.flat_file(t, patients)
    send_file t.path, :type => 'text/csv', :disposition => 'attachment', 
      :filename => 'patients_csv.csv'
    t.close
  end
  
 
  def show
    @patient = Record.find(params[:id])
    if @patient.test_id
      @vendor = Vendor.find @patient.test_id
    end
    @results = TestResult.all(:conditions => {'value.patient_id' => @patient.id}, 
      :sort => [['value.measure_id', :asc], ['value.sub_id', :asc]])
    # determine if the request was for the browser, or a C32 XML file, or CCR XML file.
    respond_to do |format|
      format.html
      format.c32 do
        render :text => HealthDataStandards::Export::C32.export(@patient)
      end
      format.ccr do
        render :text => HealthDataStandards::Export::CCR.export(@patient)
      end
      format.csv do
        render :text => HealthDataStandards::Export::CommaSV.export(@patient,true)
      end
    end
  end
end
