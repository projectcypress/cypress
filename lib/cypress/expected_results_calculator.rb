module Cypress
  class ExpectedResultsCalculator
    def initialize(patients, correlation_id)
      @correlation_id = correlation_id
      @patient_sup_map = {}
      @measure_result_hash = {}
      patients.each do |patient|
        add_patient_to_sup_map(@patient_sup_map, patient)
      end
    end

    def add_patient_to_sup_map(ps_map, patient)
      ps_map[patient.id] = {}
      ps_map[patient.id]['SEX'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.55')[0].dataElementCodes[0].code
      ps_map[patient.id]['RACE'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.59')[0].dataElementCodes[0].code
      ps_map[patient.id]['ETHNICITY'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.56')[0].dataElementCodes[0].code
      ps_map[patient.id]['PAYER'] = JSON.parse(patient.extendedData.insurance_providers).first['codes']['SOP'].first
    end

    def aggregate_results_for_measures(measures)
      measures.each do |measure|
        @measure_result_hash[measure.key] = {}
        aggregate_results_for_measure(measure)
      end
      @measure_result_hash
    end

    # rubocop:disable Metrics/AbcSize
    def aggregate_results_for_measure(measure)
      individual_results = QDM::IndividualResult.where('measure_id' => measure._id, 'extendedData.correlation_id' => @correlation_id)
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
          increment_sup_info(@patient_sup_map[ir.patient_id], pop, @measure_result_hash[measure.key])
        end

        observ_values.concat get_observ_values(ir.episode_results) if ir.episode_results
      end
      @measure_result_hash[measure.key]['OBSERV'] = median(observ_values.reject(&:nil?))
      @measure_result_hash[measure.key]['measure_id'] = measure.hqmf_id
      @measure_result_hash[measure.key]['population_ids'] = measure.population_ids
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
