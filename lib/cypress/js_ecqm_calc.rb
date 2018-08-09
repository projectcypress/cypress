require 'bunny'
require 'json'
require 'securerandom'

module Cypress
  class JsEcqmCalc
    CALCULATION_SERVICE_URL = 'http://localhost:8082/calculate'.freeze

    attr_accessor :patients, :options, :response,
                  :connection, :channel, :queue, :reply_queue, :exchange, :call_id, :condition

    def initialize(options)
      @options = options
    end

    def request(patients, measure)
      @patients = patients

      post_data = {
        patients: @patients,
        measure: measure,
        valueSetsByOid: measure.value_sets_by_oid,
        options: options
      }

      begin
        response = RestClient::Request.execute(:method => :post, :url => CALCULATION_SERVICE_URL, :timeout => 120, 
                                             :payload => post_data.to_json(methods: :_type), 
                                             :headers => {content_type: 'application/json'})
      rescue => e
        e.response
      end

      r2 = results.map do |_, result|
        result.map do |_, pop_criteria|
          pop_criteria.slice('IPP', 'DENOM', 'DENEX', 'NUMER', 'measure_id', 'patient_id', 'extendedData')
        end
      end



      raise 'No result found. Are RabbitMQ and the calculation worker Running?' unless response
      return response['result'] if response['status'] == 'success'
      raise response['error'] || 'Calculation failed without an error message'
    end

    private

    def timeout
      @options[:timeout] || 60
    end
  end
end
