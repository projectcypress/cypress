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

      # TODO: Change the return format of this to still include the measure_id and record_id
      # since they are necessary for ease of use in some calculators
      results.each do |patient_id, result|
        combined_result = CompiledResult.new(patient: @cqm_patient_mapping[patient_id],
                                             measure: measure.id,
                                             correlation_id: @correlation_id,
                                             individual_results: result)
        aggregate_population_results_from_individual_results_combined(combined_result, result)
        combined_result.save if save
        patient_result_hash[patient_id] = combined_result
      end
      patient_result_hash.values
    end

    def self.create_connection_string
      config = Rails.application.config
      "http://#{config.ces_host}:#{config.ces_port}/calculate"
    end

    private

    def aggregate_population_results_from_individual_results_combined(combined_result, individual_results)
      individual_results.each_pair do |_key, value|
        combined_result['IPP'] = true if value['IPP'].to_i.positive?
        combined_result['DENOM'] = true if value['DENOM'].to_i.positive?
        combined_result['NUMER'] = true if value['NUMER'].to_i.positive?
        combined_result['DENEX'] = true if value['DENEX'].to_i.positive?
        combined_result['DENEXCEP'] = true if value['DENEXCEP'].to_i.positive?
        combined_result['MSRPOPL'] = true if (value['MSRPOPL'].to_i - value['MSRPOPLEX'].to_i).positive?
        combined_result['MSRPOPLEX'] = true if value['MSRPOPLEX'].to_i.positive?
      end
      combined_result
    end

    def timeout
      @options[:timeout] || 60
    end
  end
end
