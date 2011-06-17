class PatientsController < ApplicationController

  require 'builder'

  before_filter :authenticate_user!

  before_filter do
    @test_id = nil
    if params[:test_id]
      @test_id = nil # use the param once we have patient generation working
    elsif params[:vendor_id]
      # find the most recent test_id for the vendor
    end
  end

  def index
    @measures = Measure.installed
    @patients = Record.all(:conditions => {'test_id' => @test_id},
      :limit => 50)
  end

  def show
    patient_id = BSON::ObjectId.from_string(params[:id])
    @patient = Record.find(params[:id])
    @results = Result.all(:conditions => {'value.patient_id' => patient_id}, 
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