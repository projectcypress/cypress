require 'json'
require 'securerandom'

module Cypress
  class CqmExecutionCalc
    attr_accessor :patients, :measures, :options

    def initialize(patients, measures, correlation_id, options)
      @patients = patients
      # This is a key -> value pair of patients mapped in the form "qdm-patient-id" => BSON::ObjectId("cqm-patient-id")
      @cqm_patient_mapping = patients.map { |patient| [patient.id.to_s, patient.tacomaPatient] }.to_h
      @measures = measures
      @correlation_id = correlation_id
      @options = options
    end

    def execute(save = true)
      results = @measures.map do |measure|
        request_for(measure, save)
      end.flatten
      results
    end

    def request_for(measure, save = true)
      post_data = { patients: @patients, measure: measure, valueSets: measure.value_sets, options: @options }
      # cqm-execution-service expects a field called value_set_oids which is really just our
      # oids field. There is a value_set_oids on the measure for this explicit purpose.
      post_data = post_data.to_json(methods: %i[_type])
      begin
        response = RestClient::Request.execute(method: :post, url: self.class.create_connection_string, timeout: 120,
                                               payload: post_data, headers: { content_type: 'application/json' })
      rescue => e
        raise e.to_s || 'Calculation failed without an error message'
      end

      results = JSON.parse(response)

      patient_result_hash = {}
      results.each do |patient_id, result|
        # Aggregate the results returned from the calculation engine for a specific patient.
        # If saving the individual results, update identifiers (patient id, population_set_key) in the individual result.
        aggregate_population_results_from_individual_results(result, @cqm_patient_mapping[patient_id], save)
        patient_result_hash[patient_id] = result.values
      end
      patient_result_hash.values
    end

    def self.create_connection_string
      config = Rails.application.config
      "http://#{config.ces_host}:#{config.ces_port}/calculate"
    end

    private

    def aggregate_population_results_from_individual_results(individual_results, patient, save)
      individual_results.each_pair do |population_set_key, individual_result|
        # store the population_set within the indivdual result
        individual_result['population_set_key'] = population_set_key
        # update the patient_id to match the cqm_patient id, not the qdm_patient id
        individual_result['patient_id'] = patient.id.to_s
        individual_result['cqm_patient'] = patient
        # save to database
        save_individual_result(individual_result) if save && individual_result.IPP != 0
        # update the patients, measure_relevance_hash
        patient.update_measure_relevance_hash(individual_result) if individual_result.IPP != 0
      end
      patient.save if save
    end

    def save_individual_result(individual_result)
      individual_result = QDM::IndividualResult.new(individual_result)
      # when saving the individual result, include the provided correlation id
      individual_result.correlation_id = @correlation_id
      # TODO: Fix in cqm-models and execution
      # Temporary fix is to strip out unneeded data to prevent saving keys containing '.'
      individual_result.extendedData = {}
      individual_result.statement_results = {}
      individual_result.save
    end

    def timeout
      @options[:timeout] || 60
    end
  end
end
