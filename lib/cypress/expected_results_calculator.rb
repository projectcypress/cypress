module Cypress
  class ExpectedResultsCalculator

    # The ExpectedResultsCalculator aggregates Individual Results to calculated the expected results for a
    # Measure Test or Task 
    #
    # @param [Array] patients the list of patients that are included in the aggregate results
    # @param [String] correlation_id the id used to associate a group of patients
    # @param [String] effective_date used when generating the query_cache_object for HDS QRDA Cat III export
    # @param [Hash] options :individual_results are the raw results from JsEcqmCalc
    def initialize(patients, correlation_id, effective_date)
      @correlation_id = correlation_id
      # Hash of patient_id and their supplemental information
      @patient_sup_map = {}
      @measure_result_hash = {}
      @effective_date = effective_date
      patients.each do |patient|
        # iterate through each patient and store their supplemental information
        add_patient_to_sup_map(@patient_sup_map, patient)
      end
    end

    def add_patient_to_sup_map(ps_map, patient)
      patient_id = patient.id.to_s
      ps_map[patient_id] = {}
      ps_map[patient_id]['SEX'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.55')[0].dataElementCodes[0].code
      ps_map[patient_id]['RACE'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.59')[0].dataElementCodes[0].code
      ps_map[patient_id]['ETHNICITY'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.56')[0].dataElementCodes[0].code
      ps_map[patient_id]['PAYER'] = JSON.parse(patient.extendedData.insurance_providers).first['codes']['SOP'].first
    end

    def aggregate_results_for_measures(measures, individual_results = nil)
      measures.each do |measure|
        @measure_result_hash[measure.key] = {}
        measure_individual_results = nil
        measure_individual_results = individual_results[measure.id.to_s].values if individual_results
        aggregate_results_for_measure(measure, measure_individual_results)
      end
      @measure_result_hash
    end

    # rubocop:disable Metrics/AbcSize
    def aggregate_results_for_measure(measure, individual_results = nil)
      individual_results ||= QDM::IndividualResult.where('measure_id' => measure._id, 'extendedData.correlation_id' => @correlation_id)
      measure_populations = %w[DENOM NUMER DENEX DENEXCEP IPP MSRPOPL MSRPOPLEX]
      @measure_result_hash[measure.key]['supplemental_data'] = {}
      measure_populations.each do |pop|
        @measure_result_hash[measure.key][pop] = 0
      end
      observ_values = []
      individual_results.each do |ir|
        measure_populations.each do |pop|
          next if ir[pop].nil? || ir[pop].zero?
          @measure_result_hash[measure.key][pop] += ir[pop]
          increment_sup_info(@patient_sup_map[ir.patient_id.to_s], pop, @measure_result_hash[measure.key])
        end
        observ_values.concat get_observ_values(ir['episode_results']) if ir['episode_results']
      end
      @measure_result_hash[measure.key]['OBSERV'] = median(observ_values.reject(&:nil?))
      @measure_result_hash[measure.key]['measure_id'] = measure.hqmf_id
      @measure_result_hash[measure.key]['population_ids'] = measure.population_ids
      create_query_cache_object(@measure_result_hash[measure.key], measure)
    end
    # rubocop:enable Metrics/AbcSize

    def get_observ_values(episode_results)
      episode_results.collect_concat do |_id, episode_result|
        next unless episode_result['MSRPOPL']&.positive? && !episode_result['MSRPOPLEX']&.positive?
        episode_result['values']
      end
    end

    def increment_sup_info(patient_sup, pop, single_measure_result_hash)
      unless single_measure_result_hash['supplemental_data'][pop]
        single_measure_result_hash['supplemental_data'][pop] = { 'RACE' => {}, 'ETHNICITY' => {}, 'SEX' => {}, 'PAYER' => {} }
      end
      patient_sup.keys.each do |sup_type|
        add_or_increment_code(pop, sup_type, patient_sup[sup_type], single_measure_result_hash)
      end
    end

    def add_or_increment_code(pop, sup_type, code, single_measure_result_hash)
      if single_measure_result_hash['supplemental_data'][pop][sup_type][code]
        single_measure_result_hash['supplemental_data'][pop][sup_type][code] += 1
      else
        single_measure_result_hash['supplemental_data'][pop][sup_type][code] = 1
      end
    end

    def create_query_cache_object(result, measure)
      qco = result
      qco['test_id'] = BSON::ObjectId.from_string(@correlation_id)
      qco['effective_date'] = @effective_date
      qco['sub_id'] = measure.sub_id if measure.sub_id
      Mongoid.default_client['query_cache'].insert_one(qco)
    end

    private

    def mean(array)
      return 0.0 if array.empty?
      array.inject(0.0) { |sum, elem| sum + elem } / array.size
    end

    def median(array, already_sorted = false)
      return 0.0 if array.empty?
      array = array.sort unless already_sorted
      m_pos = array.size / 2
      array.size.odd? ? array[m_pos] : mean(array[m_pos - 1..m_pos])
    end
  end
end
