module Validators
  class ExpectedResultsValidator < QrdaFileValidator
    include ::CqmValidators::ReportedResultExtractor
    include Validators::Validator
    attr_accessor :reported_results

    def initialize(expected_results)
      @expected_results = expected_results
    end

    def validate(file, options = {})
      @document = get_document(file)
      @file_name = options[:file_name]
      @expected_results.each do |measure_expected_result|
        measure_expected_result.population_set_results.each do |expected_result|
          measure = Measure.find(measure_expected_result.measure_id)
          psk = expected_result.population_set_key
          pop_set_hash = measure.population_set_hash_for_key(psk)
          reported_result, _errors = extract_results_by_ids(measure, pop_set_hash[:population_set_id], @document, pop_set_hash[:stratification_id])
          if reported_result
            compare_results(expected_result, reported_result.population_set_results.first, measure)
          else
            add_error("Cannot find #{psk} for #{measure.cms_id}", location: '/', file_name: @file_name)
          end
        end
      end
    end

    private

    def compare_results(expected_result, reported_result, measure)
      measure_identifiers = find_measure_identifiers(expected_result, measure)
      compare_population_results(expected_result, reported_result, measure_identifiers)
      not_matched, missing_expected, extra_reported = compare_supplemental_information(expected_result, reported_result)
      not_matched.each { |nm| add_sup_data_error(nm[:expected_result], nm[:reported_result], measure_identifiers) }
      missing_expected.each { |me| add_sup_data_error(me, nil, measure_identifiers) }
      extra_reported.each { |er| add_sup_data_error(nil, er, measure_identifiers) }
    end

    def find_measure_identifiers(expected_result, measure)
      population_set = measure.population_sets.where(population_set_id: expected_result[:population_set_id]).first
      population_ids = {}
      measure.population_keys.each do |population|
        population_ids[population] = population_set.populations[population].hqmf_id
      end
      population_ids['OBSERV'] = population_set.observations.first.hqmf_id if measure.measure_scoring == 'CONTINUOUS_VARIABLE'
      stratification_id = if expected_result[:stratification_id]
                            population_set.stratifications.where(stratification_id: expected_result[:stratification_id]).first.hqmf_id
                          end
      { measure_id: measure.hqmf_id, population_ids: population_ids, stratification_id: stratification_id }
    end

    def compare_population_results(expected_result, reported_result, measure_identifiers)
      measure_identifiers.population_ids.keys.each do |population|
        unless expected_result[:stratification_id] || population == 'OBSERV'
          check_supplemental_data_matches_pop_sums(expected_result, reported_result, population, measure_identifiers)
        end
        next if expected_result[population] == reported_result[population]

        generate_does_not_match_population_error_message(measure_identifiers[:measure_id], measure_identifiers[:population_ids][population],
                                                         population, measure_identifiers[:stratification_id], expected_result, reported_result)
      end
    end

    def compare_supplemental_information(expected_result, reported_result)
      replace_cms_payer_codes(reported_result)
      not_matched = []
      missing_expected = []
      expected_supp_info = expected_result.supplemental_information.sort_by { |si| "#{si.population}_#{si.code}" }
      reported_supp_info = reported_result.supplemental_information.sort_by { |si| "#{si.population}_#{si.code}" }

      until expected_supp_info.empty?
        expected = expected_supp_info.shift
        reported = reported_supp_info.select { |si| si.population == expected.population && si.code == expected.code }&.first

        # This checks to see if there is a reported value that corresponds with the expected value
        if reported
          counts_match = reported.patient_count == expected.patient_count || expected.acceptable_patient_count.include?(reported.patient_count)
          not_matched << { expected_result: expected, reported_result: reported } unless counts_match
          reported_supp_info.delete(reported)
        else
          missing_expected << expected unless expected.acceptable_patient_count.include?(0)
        end
      end
      [not_matched, missing_expected, reported_supp_info]
    end

    def replace_cms_payer_codes(reported_result)
      reported_result.supplemental_information.select { |si| si.key == 'PAYER' }.each do |payer_si|
        translated_payer_code = APP_CONSTANTS['randomization']['payers'].find { |p| p['codeCMS'].to_s == payer_si.code }
        next unless translated_payer_code

        payer_si.code = translated_payer_code.code.to_s
      end
    end

    def check_supplemental_data_matches_pop_sums(expected_result, reported_result, population, measure_identifiers)
      expected_supplemental_information = expected_result.supplemental_information.select { |si| si.key == 'SEX' && si.population == population }
      pop_sum = expected_supplemental_information.map(&:patient_count).reduce(:+) || 0
      %w[ETHNICITY PAYER RACE SEX].each do |si_key|
        reported_supplemental_information = reported_result.supplemental_information.select { |si| si.key == si_key && si.population == population }
        sup_sum = reported_supplemental_information.map(&:patient_count).reduce(:+) || 0
        next if pop_sum == sup_sum

        err = %(Reported #{population} value #{pop_sum} does not match \
              sum #{sup_sum} of supplemental key #{si_key} values)
        error_details = { type: 'population_sum', population_id: measure_identifiers[:population_ids][population],
                          stratification: measure_identifiers[:stratification_id], expected_value: pop_sum, reported_value: sup_sum }
        options = { location: '/', measure_id: measure_identifiers[:measure_id], error_details: error_details, file_name: @file_name }
        add_error(err, options)
      end
    end

    def generate_does_not_match_population_error_message(measure_id, population_id, pop_key, stratification_id, expected_result, reported_result)
      err = %(Expected #{pop_key} value #{expected_result[pop_key]}
      does not match reported value #{reported_result[pop_key]})
      error_details = { type: 'population', population_id: population_id, stratification: stratification_id,
                        expected_value: expected_result[pop_key], reported_value: reported_result[pop_key] }
      options = { location: '/', measure_id: measure_id, error_details: error_details, file_name: @file_name }
      add_error(err, options)
    end

    # def generate_could_not_find_population_error_message(measure_id, population_id, pop_key, pop_set_hash, stratification_id)
    #   message = 'Could not find value'
    #   message += " for stratification #{stratification_id} " if pop_set_hash[:stratification_id]
    #   message += " for Population #{pop_key}"
    #   add_error(message, location: '/', measure_id: measure_id, population_id: population_id, stratification: stratification_id)
    # end

    def add_sup_data_error(expected_result, reported_result, measure_identifiers)
      expected_count = expected_result ? expected_patient_count(expected_result) : 0
      reported_count = reported_result ? reported_result.patient_count : 0
      population = expected_result ? expected_result.population : reported_result.population
      return if population == 'OBSERV'

      data_type = expected_result ? expected_result.key : reported_result.key
      code = expected_result ? expected_result.code : reported_result.code
      error_details = { type: 'supplemental_data', population_key: population, data_type: data_type, reported_value: reported_count,
                        population_id: measure_identifiers[:population_ids][population], code: code, expected_value: expected_count }
      options = { location: '/', measure_id: measure_identifiers[:measure_id], error_details: error_details, file_name: @file_name }
      add_error('supplemental data error', options)
    end

    def expected_patient_count(expected_result)
      expected_result.acceptable_patient_count.empty? ? expected_result.patient_count : expected_result.acceptable_patient_count
    end
  end
end
