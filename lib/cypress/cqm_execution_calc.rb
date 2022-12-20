# frozen_string_literal: true

require 'json'
require 'securerandom'

module Cypress
  class CqmExecutionCalc
    attr_accessor :patients, :measures, :options

    def initialize(patients, measures, correlation_id, options)
      @patients = patients
      is_qdm55 = Bundle.only(:version).find(measures.first.bundle_id).major_version.to_i < 2022
      @connection_string = is_qdm55 ? self.class.create_55_connection_string : self.class.create_56_connection_string
      # This is a key -> value pair of patients mapped in the form "qdm-patient-id" => BSON::ObjectId("cqm-patient-id")
      @cqm_patient_mapping = patients.to_h { |patient| [patient.id.to_s, patient.cqmPatient] }
      @measures = measures
      @correlation_id = correlation_id
      @options = options
    end

    def execute(save: true)
      @measures.map do |measure|
        request_for(measure, save: save)
      end.flatten
    end

    def request_for(measure, save: true)
      ir_list = []
      @options['requestDocument'] = true
      post_data = { patients: @patients, measure: measure, valueSets: measure.value_sets, options: @options }
      # cqm-execution-service expects a field called value_set_oids which is really just our
      # oids field. There is a value_set_oids on the measure for this explicit purpose.
      post_data = post_data.to_json(methods: %i[_type])
      begin
        response = RestClient::Request.execute(method: :post, url: @connection_string, timeout: 120,
                                               payload: post_data, headers: { content_type: 'application/json' })
      rescue StandardError => e
        raise e.to_s || 'Calculation failed without an error message'
      end
      results = JSON.parse(response)

      patient_result_hash = {}
      results.each do |patient_id, result|
        # Aggregate the results returned from the calculation engine for a specific patient.
        # If saving the individual results, update identifiers (patient id, population_set_key) in the individual result.
        aggregate_population_results_from_individual_results(result, @cqm_patient_mapping[patient_id], save, ir_list, measure)
        patient_result_hash[patient_id] = result.values
      end
      measure.calculation_results.create(ir_list) if save
      patient_result_hash.values
    end

    def self.create_55_connection_string
      config = Rails.application.config
      "http://#{config.ces_55_host}:#{config.ces_55_port}/calculate"
    end

    def self.create_56_connection_string
      config = Rails.application.config
      "http://#{config.ces_56_host}:#{config.ces_56_port}/calculate"
    end

    private

    def aggregate_population_results_from_individual_results(individual_results, patient, save, ir_list, measure)
      individual_results.each_pair do |population_set_key, individual_result|
        # store the population_set within the indivdual result
        individual_result['population_set_key'] = population_set_key
        # update the patient_id to match the cqm_patient id, not the qdm_patient id
        individual_result['patient_id'] = patient.id.to_s
        # save to database (if in the IPP)
        ir_list << postprocess_individual_result(individual_result) if save && patient_relevant_to_ipp(individual_result, measure)
        # update the patients, measure_relevance_hash
        patient.update_measure_relevance_hash(individual_result) if patient_relevant_to_ipp(individual_result, measure)
      end
      patient.save if save
    end

    def patient_relevant_to_ipp(individual_result, measure)
      measure.individual_result_relevant_to_measure(individual_result)
    end

    # This add/remove information for use in Cypress
    # extendedData and statement_results are currently remove as a remporary fix
    # Add correlation_id for searchability
    def postprocess_individual_result(individual_result)
      # individual_result = CQM::IndividualResult.new(individual_result)
      # when saving the individual result, include the provided correlation id
      individual_result['correlation_id'] = @correlation_id
      individual_result
    end

    def timeout
      @options[:timeout] || 60
    end
  end
end
