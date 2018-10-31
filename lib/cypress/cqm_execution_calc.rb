require 'json'
require 'securerandom'

module Cypress
  class CqmExecutionCalc
    attr_accessor :patients, :measures, :value_set_oids, :options

    def initialize(patients, measures, value_set_oids, correlation_id, options)
      @patients = patients
      # This is a key -> value pair of patients mapped in the form "qdm-patient-id" => BSON::ObjectId("cqm-patient-id")
      @cqm_patient_mapping = patients.map { |patient| [patient.id.to_s, patient.tacomaPatient.id] }.to_h
      @measures = measures
      @value_set_oids = value_set_oids
      @correlation_id = correlation_id
      @options = options
    end

    def execute(save = true)
      results = @measures.map do |measure|
        request_for(measure)
      end.flatten
      CQM::IndividualResult.collection.insert_many(results) if save
      results
    end

    def request_for(measure)
      post_data = { patients: @patients, measure: measure, valueSetsByOid: measure.value_sets_by_oid, options: @options }
      # cqm-execution-service expects a field called value_set_oids which is really just our
      # oids field. There is a value_set_oids on the measure for this explicit purpose.
      post_data = post_data.to_json(methods: %i[_type value_set_oids])
      begin
        response = RestClient::Request.execute(method: :post, url: create_connection_string, :timeout: 120,
                                               payload: post_data, headers: { content_type: 'application/json' })
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
          # Find the correct BSON::ObjectId("cqm-patient-id") based on the qdm-patient-id
          pop_criteria['patient_id'] = @cqm_patient_mapping[pop_criteria['patient_id']]
          pop_criteria['state'] = 'complete'
          pop_criteria['extendedData'] = @correlation_id ? { 'correlation_id' => @correlation_id } : {}
          pop_criteria
        end
      end
    end

    def self.create_connection_string
      config = Rails.application.config
      "http://#{config.ces_host}:#{config.ces_port}"
    end

    private

    def timeout
      @options[:timeout] || 60
    end
  end
end
