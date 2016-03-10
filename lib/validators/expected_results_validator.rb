module Validators
  class ExpectedResultsValidator < QrdaFileValidator
    include HealthDataStandards::Validate::ReportedResultExtractor
    include Validators::Validator
    attr_accessor :reported_results

    def initialize(expected_results)
      @expected_results = expected_results
      @reported_results = {}
    end

    # Nothing to see here - Move along
    def validate(file, options = {})
      @document = get_document(file)
      @expected_results.each_pair do |key, expected_result|
        result_key = expected_result['population_ids'].dup
        reported_result, _errors = extract_results_by_ids(expected_result['measure_id'], result_key, @document)
        @reported_results[key] = reported_result
        match_calculation_results(expected_result, reported_result)
      end
      options[:reported_result_target].reported_results = reported_results if options[:reported_result_target]
    end

    private

    def match_calculation_results(expected_result, reported_result)
      measure_id = expected_result['measure_id']
      check_for_reported_results_population_ids(expected_result, reported_result, measure_id)
      ids = expected_result['population_ids'].dup
      # remove the stratification entry if its there, not needed to test against values
      stratification = ids.delete('stratification')
      stratification ||= ids.delete('STRAT')
      ids.keys.each do |pop_key|
        next unless expected_result[pop_key].present?
        check_population(expected_result, reported_result, pop_key, stratification, measure_id)
        # Check supplemental data elements
        ex_sup = (expected_result['supplemental_data'] || {})[pop_key]
        reported_sup = (reported_result[:supplemental_data] || {})[pop_key]
        next unless stratification.nil? && ex_sup

        sup_keys = ex_sup.keys.reject(&:blank?)

        # for each supplemental data item (RACE, ETHNICITY, PAYER, SEX)
        sup_keys.each do |sup_key|
          expect_sup_val = (ex_sup[sup_key] || {}).reject { |k, v| (k.blank? || v.blank? || v == 'UNK') }
          report_sup_val = reported_sup.nil? ? nil : reported_sup[sup_key]
          # keys_and_ids used to hold information that is displayed with an execution error. the variable also rhymes
          keys_and_ids = { measure_id: measure_id, pop_key: pop_key, sup_key: sup_key }
          check_supplemental_data_expected_not_reported(expect_sup_val, report_sup_val, keys_and_ids)
          check_supplemental_data_reported_not_expected(expect_sup_val, report_sup_val, keys_and_ids)
        end
      end
    end

    def check_for_reported_results_population_ids(expected_result, reported_result, measure_id)
      ids = expected_result['population_ids'].dup
      if reported_result.nil? || reported_result.keys.length <= 1
        message = %("Could not find entry for measure #{expected_result['measure_id']} with the following population ids ")
        message += ids.inspect
        # logger.call(message, _ids['stratification'])
        add_error(message, :location => '/', :validator_type => :result_validation,
                           :measure_id => measure_id, :stratification => ids['stratification'])
      end
    end

    def check_population(expected_result, reported_result, pop_key, stratification, measure_id)
      # only add the error that they dont match if there was an actual result
      if !reported_result.empty? && !reported_result.key?(pop_key)
        message = 'Could not find value'
        message += " for stratification #{stratification} " if stratification
        message += " for Population #{pop_key}"
        add_error(message, :location => '/', :validator_type => :result_validation,
                           :measure_id => measure_id, :stratification => stratification)
      elsif (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?
        err = %(expected #{pop_key} #{expected_result['population_ids'][pop_key]} value #{expected_result[pop_key]}
        does not match reported value #{reported_result[pop_key]})
        add_error(err, :location => '/', :validator_type => :result_validation,
                       :measure_id => measure_id, :stratification => stratification)
      end
    end

    def check_supplemental_data_expected_not_reported(expect_sup_val, report_sup_val, keys_and_ids)
      expect_sup_val.each_pair do |code, expect_val|
        if report_sup_val.nil? || (code != 'UNK' && expect_val != report_sup_val[code])
          report_val = report_sup_val.nil? ? 0 : report_sup_val[code]
          add_sup_data_error(keys_and_ids, code, expect_val, report_val)
        end
      end
    end

    def check_supplemental_data_reported_not_expected(expect_sup_val, report_sup_val, keys_and_ids)
      return if report_sup_val.nil?
      report_sup_val.each_pair do |code, report_val|
        add_sup_data_error(keys_and_ids, code, 0, report_val) if report_val > 0 && expect_sup_val[code].nil?
      end
    end

    def add_sup_data_error(keys_and_ids, code, expect_val, report_val)
      error_details = { type: 'supplemental_data', population_key: keys_and_ids.pop_key, data_type: keys_and_ids.sup_key,
                        code: code, expected_value: expect_val, reported_value: report_val }
      options = { :location => '/', :measure_id => keys_and_ids.measure_id, :validator_type => :result_validation, :error_details => error_details }
      add_error('supplemental data error', options)
    end
  end
end
