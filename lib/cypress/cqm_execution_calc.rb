require 'json'
require 'securerandom'

module Cypress
  class CqmExecutionCalc
    attr_accessor :patients, :measures, :options

    def initialize(patients, measures, correlation_id, options)
      @patients = patients
      # This is a key -> value pair of patients mapped in the form "qdm-patient-id" => BSON::ObjectId("cqm-patient-id")
      @cqm_patient_mapping = patients.map { |patient| [patient.id.to_s, patient.cqmPatient] }.to_h
      @measures = measures
      @correlation_id = correlation_id
      @options = options
      @ir_list = []
    end

    def execute(save = true)
      results = @measures.map do |measure|
        request_for(measure, save)
      end.flatten
      IndividualResult.create!(@ir_list) if save
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
        # save to database (if in the IPP, or has a file name (i.e., a file that was uploaded for CVU+))
        @ir_list << postprocess_individual_result(individual_result) if save && (individual_result.IPP != 0 || @options[:file_name])
        # update the patients, measure_relevance_hash
        patient.update_measure_relevance_hash(individual_result) if individual_result.IPP != 0
      end
      patient.save if save
    end

    # This add/remove information for use in Cypress
    # extendedData and statement_results are currently remove as a remporary fix
    # Add correlation_id and file_name for searchability
    def postprocess_individual_result(individual_result)
      # individual_result = CQM::IndividualResult.new(individual_result)
      # when saving the individual result, include the provided correlation id
      individual_result['correlation_id'] = @correlation_id
      individual_result['file_name'] = @options[:file_name] if @options[:file_name]
      individual_result
    end

    def timeout
      @options[:timeout] || 60
    end
  end
end
