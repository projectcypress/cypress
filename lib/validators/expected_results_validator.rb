module Validators
  class ExpectedResultsValidator < QrdaFileValidator
    include ::CqmValidators::ReportedResultExtractor
    include Validators::Validator
    attr_accessor :reported_results

    self.validator = :expected_results

    def initialize(expected_results)
      @expected_results = expected_results
      @reported_results = {}
    end

    # Nothing to see here - Move along
    def validate(file, options = {})
      @document = get_document(file)
      @file_name = options[:file_name]
      @modified_population_labels = options['task'].bundle.modified_population_labels
      @expected_results.each_pair do |key, expected_result|
        expected_result = update_expected_population_ids(expected_result) if @modified_population_labels
        result_key = expected_result['population_ids'].dup
        reported_result, _errors = extract_results_by_ids(expected_result['measure_id'], result_key, @document)
        @reported_results[key] = reported_result
        match_calculation_results(expected_result, reported_result, options)
      end
      options[:reported_result_target]&.reported_results = reported_results
    end

    private

    def match_calculation_results(expected_result, reported_result, options)
      measure_id = expected_result['measure_id']
      check_for_reported_results_population_ids(expected_result, reported_result, measure_id)
      ids = expected_result['population_ids'].dup
      # remove the stratification entry if its there, not needed to test against values
      stratification = ids.delete('stratification')
      stratification ||= ids.delete('STRAT')
      ids.each do |pop_key, pop_id|
        next if expected_result[pop_key].blank?

        check_population(expected_result, reported_result, pop_key, stratification, measure_id)
        # Check supplemental data elements
        ex_sup = (expected_result['supplemental_data'] || {})[pop_key]
        next unless stratification.nil? && ex_sup

        keys_and_ids = { measure_id: measure_id, pop_key: pop_key, pop_id: pop_id }

        check_sup_keys(ex_sup, reported_result, keys_and_ids, stratification, options)
      end
    end

    # Labels for populations can change over time, this will replace the QME population code with the code used in the specified qrda version
    # e.g. IPP is IPOP in QRDA Cat III R1.1
    def update_expected_population_ids(expected_result)
      @modified_population_labels.each do |original_label, modified_label|
        expected_result[modified_label] = expected_result[original_label]
        expected_result.delete(original_label)
        expected_result['population_ids'][modified_label] = expected_result['population_ids'][original_label]
        expected_result['population_ids'].delete(original_label)
        expected_result['supplemental_data'][modified_label] = expected_result['supplemental_data'][original_label]
        expected_result['supplemental_data'].delete(original_label)
      end
      expected_result
    end

    def check_for_reported_results_population_ids(expected_result, reported_result, measure_id)
      ids = expected_result['population_ids'].dup
      if reported_result.nil? || reported_result.keys.length <= 1
        message = %("Could not find entry for measure #{expected_result['measure_id']} with the following population ids ")
        message += ids.inspect
        # logger.call(message, _ids['stratification'])
        add_error(message, location: '/', measure_id: measure_id, stratification: ids['stratification'], file_name: @file_name)
      end
    end

    def check_population(expected_result, reported_result, pop_key, stratification, measure_id)
      # only add the error that they dont match if there was an actual result
      if !reported_result.empty? && !reported_result.key?(pop_key)
        message = 'Could not find value'
        message += " for stratification #{stratification} " if stratification
        message += " for Population #{pop_key}"
        add_error(message, location: '/', measure_id: measure_id, stratification: stratification)
      elsif (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?
        err = %(Expected #{pop_key} #{expected_result['population_ids'][pop_key]} value #{expected_result[pop_key]}
        does not match reported value #{reported_result[pop_key]})
        error_details = { type: 'population', population_id: expected_result['population_ids'][pop_key], stratification: stratification,
                          expected_value: expected_result[pop_key], reported_value: reported_result[pop_key] }
        options = { location: '/', measure_id: measure_id, error_details: error_details, file_name: @file_name }
        add_error(err, options)
      end
    end

    def check_sup_keys(ex_sup, reported_result, keys_and_ids, stratification, options)
      esr = ExpectedSupplementalResults.new(@file_name)
      sup_keys = ex_sup.keys.reject(&:blank?)
      reported_sup = (reported_result[:supplemental_data] || {})[keys_and_ids[:pop_key]]

      # for each supplemental data item (RACE, ETHNICITY, PAYER, SEX)
      sup_keys.each do |sup_key|
        expect_sup_val = (ex_sup[sup_key] || {}).reject { |k, v| (k.blank? || v.blank? || v == 'UNK') }
        report_sup_val = reported_sup.nil? ? nil : reported_sup[sup_key]
        # keys_and_ids used to hold information that is displayed with an execution error. the variable also rhymes
        keys_and_ids[:sup_key] = sup_key
        esr.check_supplemental_data_matches_pop_sums(report_sup_val, keys_and_ids, expect_sup_val, stratification)
        esr.check_supplemental_data_expected_not_reported(expect_sup_val, report_sup_val, keys_and_ids, @modified_population_labels, options)
        esr.check_supplemental_data_reported_not_expected(expect_sup_val, report_sup_val, keys_and_ids, @modified_population_labels, options)
      end
      @errors.nil? ? (@errors = esr.errors) : @errors.concat(esr.errors || [])
    end
  end
end
