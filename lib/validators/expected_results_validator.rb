# frozen_string_literal: true

module Validators
  class ExpectedResultsValidator < QrdaFileValidator
    include ::CqmValidators::ReportedResultExtractor
    include Validators::Validator
    attr_accessor :reported_results

    def initialize(expected_results)
      @expected_results = expected_results
      @reported_results = {}
    end

    def validate(file, options = {})
      @document = get_document(file)
      @file_name = options[:file_name]
      if @expected_results.nil?
        add_warning('Expected Results were not calculated for this test.', location: '/')
      else
        @expected_results.each_pair do |hqmf_id, measure_expected_result|
          measure_expected_result.each_pair do |key, expected_result|
            measure = Measure.where(hqmf_id:).first
            pop_set_hash = measure.population_set_hash_for_key(key)
            reported_result, _errors = extract_results_by_ids(measure, pop_set_hash[:population_set_id], @document, pop_set_hash[:stratification_id])
            @reported_results[key] = reported_result
            match_calculation_results(expected_result, reported_result, options, measure, pop_set_hash)
          end
        end
      end
      options[:reported_result_target]&.reported_results = reported_results
    end

    private

    def match_calculation_results(expected_result, reported_result, options, measure, pop_set_hash)
      population_set = measure.population_sets.where(population_set_id: pop_set_hash[:population_set_id]).first
      measure.population_keys.each do |pop_key|
        next unless population_set.populations[pop_key]&.hqmf_id

        stratification_id = population_set.stratifications.where(stratification_id: pop_set_hash[:stratification_id]).first&.hqmf_id
        check_population(expected_result, reported_result, pop_key, pop_set_hash, measure)

        # Check supplemental data elements
        ex_sup = (expected_result['supplemental_data'] || {})[pop_key]
        next unless pop_set_hash[:stratification_id].nil? && ex_sup

        keys_and_ids = { measure_id: measure.hqmf_id,
                         pop_key:,
                         pop_id: population_set.populations[pop_key].hqmf_id,
                         stratification_id: }

        check_sup_keys(ex_sup, reported_result, keys_and_ids, options)
      end
      check_observations(expected_result, reported_result, measure.hqmf_id) if expected_result[:observations]
    end

    # def check_for_reported_results_population_ids(expected_result, reported_result, measure_id, stratification_id)
    #   #ids = expected_result['population_ids'].dup
    #   if reported_result.nil? || reported_result.keys.length <= 1
    #     message = %("Could not find entry for measure #{expected_result['measure_id']} with the following population ids ")
    #     #message += ids.inspect
    #     # logger.call(message, _ids['stratification'])
    #     add_error(message, location: '/', measure_id: measure_id, stratification: stratification_id, file_name: @file_name)
    #   end
    # end

    def check_observations(expected_result, reported_result, measure_id)
      expected_result[:observations].each do |population, expected_observation|
        next if reported_result[:observations][population].to_d == expected_observation['value'].to_d
        # CQL requires a minimum of 8 decimal values.  Cap our check there.
        next if reported_result[:observations][population].to_d.round(8) == expected_observation['value'].to_d.round(8)

        err = %(Expected #{population} Observation value #{expected_observation['value']}
        does not match reported value #{reported_result[:observations][population]})
        options = { location: '/', measure_id:, file_name: @file_name }
        add_error(err, options)
      end
    end

    def check_population(expected_result, reported_result, pop_key, pop_set_hash, measure)
      # only add the error that they dont match if there was an actual result
      population_set = measure.population_sets.where(population_set_id: pop_set_hash[:population_set_id]).first
      population_id = population_set.populations[pop_key].hqmf_id
      stratification_id = if pop_set_hash[:stratification_id]
                            population_set.stratifications.where(stratification_id: pop_set_hash[:stratification_id]).first.hqmf_id
                          end
      if !reported_result.empty? && !reported_result.key?(pop_key)
        generate_could_not_find_population_error_message(measure.hqmf_id, population_id, pop_key, pop_set_hash, stratification_id)
      elsif (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?
        generate_does_not_match_population_error_message(measure.hqmf_id, population_id, pop_key, stratification_id, expected_result, reported_result)
      end
    end

    def generate_could_not_find_population_error_message(measure_id, population_id, pop_key, pop_set_hash, stratification_id)
      message = 'Could not find value'
      message += " for stratification #{stratification_id} " if pop_set_hash[:stratification_id]
      message += " for Population #{pop_key}"
      add_error(message, location: '/', measure_id:, population_id:, stratification: stratification_id)
    end

    def generate_does_not_match_population_error_message(measure_id, population_id, pop_key, stratification_id, expected_result, reported_result)
      err = %(Expected #{pop_key} value #{expected_result[pop_key]}
      does not match reported value #{reported_result[pop_key]})
      error_details = { type: 'population', population_id:, stratification: stratification_id,
                        expected_value: expected_result[pop_key], reported_value: reported_result[pop_key] }
      options = { location: '/', measure_id:, error_details:, file_name: @file_name }
      add_error(err, options)
    end

    def check_sup_keys(ex_sup, reported_result, keys_and_ids, options)
      esr = ExpectedSupplementalResults.new(@file_name)
      sup_keys = ex_sup.keys.reject(&:blank?)
      reported_sup = (reported_result[:supplemental_data] || {})[keys_and_ids[:pop_key]]

      # for each supplemental data item (RACE, ETHNICITY, PAYER, SEX)
      sup_keys.each do |sup_key|
        expect_sup_val = (ex_sup[sup_key] || {}).reject { |k, v| k.blank? || v.blank? || v == 'UNK' }
        report_sup_val = reported_sup.nil? ? nil : reported_sup[sup_key]
        # keys_and_ids used to hold information that is displayed with an execution error. the variable also rhymes
        keys_and_ids[:sup_key] = sup_key
        esr.check_supplemental_data_matches_pop_sums(report_sup_val, keys_and_ids, expect_sup_val)
        esr.check_supplemental_data_expected_not_reported(expect_sup_val, report_sup_val, keys_and_ids, options)
        esr.check_supplemental_data_reported_not_expected(expect_sup_val, report_sup_val, keys_and_ids, options)
      end
      @errors.nil? ? (@errors = esr.errors) : @errors.concat(esr.errors || [])
    end
  end
end
