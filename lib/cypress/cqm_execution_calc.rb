require 'json'
require 'securerandom'

module Cypress
  class CqmExecutionCalc
    CALCULATION_SERVICE_URL = 'http://localhost:8081/calculate'.freeze

    attr_accessor :patients, :measures, :value_set_oids, :options

    def initialize(patients, measures, value_set_oids, correlation_id, options)
      @patients = patients
      @measures = measures
      @value_set_oids = value_set_oids
      @correlation_id = correlation_id
      @options = options
    end

    def execute
      results = @measures.map do |measure|
        request_for(measure)
      end.flatten
      QDM::IndividualResult.collection.insert_many(results)
      results
    end

    def request_for(measure)
      post_data = { patients: @patients, measure: measure, valueSetsByOid: measure.value_sets_by_oid, options: @options }
      # cqm-execution-service expects a field called value_set_oids which is really just our
      # oids field. There is a value_set_oids on the measure for this explicit purpose.
      post_data = post_data.to_json(methods: %i[_type value_set_oids])
      begin
        response = RestClient::Request.execute(:method => :post, :url => CALCULATION_SERVICE_URL, :timeout => 120,
                                               :payload => post_data, :headers => { :content_type => 'application/json' })
      rescue => e
        raise e.to_s || 'Calculation failed without an error message'
      end

      results = JSON.parse(response)

      # TODO: Change the return format of this to still include the measure_id and record_id
      # since they are necessary for ease of use in some calculators
      results.map do |_, result|
        result.map do |_, pop_criteria|
          pop_criteria.slice!('IPP', 'DENOM', 'DENEX', 'NUMER', 'measure_id', 'patient_id')
          pop_criteria['measure_id'] = BSON::ObjectId.from_string(pop_criteria['measure_id'])
          pop_criteria['patient_id'] = BSON::ObjectId.from_string(pop_criteria['patient_id'])
          pop_criteria['state'] = 'complete'
          pop_criteria['extendedData'] = @correlation_id ? { 'correlation_id' => @correlation_id } : {}
          pop_criteria
        end
      end
    end

    private

    def timeout
      @options[:timeout] || 60
    end
  end
end
