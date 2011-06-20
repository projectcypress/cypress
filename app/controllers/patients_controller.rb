require 'measure_evaluator'

class PatientsController < ApplicationController

  require 'builder'

  before_filter :authenticate_user!

  def index
    @measures = Measure.installed
    if params[:measure_id]
      @selected = Measure.find(params[:measure_id])
    else
      @selected = @measures[0]
    end
    @result = Cypress::MeasureEvaluator.eval_for_static_records(@selected)
    @patients = Result.where("value.test_id" => nil).where("value.measure_id" => @selected['id'])
      .where("value.sub_id" => @selected.sub_id).where("value.population" => true)
      .order_by([["value.numerator", :desc],["value.denominator", :desc],["value.exclusions", :desc]])    
  end

  def show
    @patient = Record.find(params[:id])
    if @patient.test_id
      @vendor = Vendor.find @patient.test_id
    end
    @results = Result.all(:conditions => {'value.patient_id' => @patient.id}, 
      :sort => [['value.measure_id', :asc], ['value.sub_id', :asc]])
    # determine if the request was for the browser, or a C32 XML file, or CCR XML file.
    respond_to do |format|
      format.html
      format.c32 do
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        send_data @patient.to_c32(xml),
          :filename => "#{@patient.id}.xml",
          :type => 'application/x-download'
      end
      format.ccr do
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        send_data @patient.to_ccr(xml),
          :filename => "#{@patient.id}.xml",
          :type => 'application/x-download'
      end
    end
  end
end