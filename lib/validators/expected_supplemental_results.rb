module Validators
  # This is a set of helper methods to validate reported supplemental values associated
  # with a population key against reported ones.
  class ExpectedSupplementalResults < QrdaFileValidator
    include Validators::Validator

    def initialize(file_name)
      @file_name = file_name
      super()
    end

    def check_supplemental_data_matches_pop_sums(report_sup_val, keys_and_ids, expect_sup_val, stratification)
      pop_sum = expect_sup_val.values.reduce(:+) || 0
      sup_sum = 0
      report_sup_val&.each { |sup_set| sup_sum += sup_set[1] }
      if pop_sum != sup_sum
        err = %(Reported #{keys_and_ids[:pop_key]} #{keys_and_ids[:pop_id]} value #{pop_sum} does not match \
sum #{sup_sum} of supplemental key #{keys_and_ids[:sup_key]} values)
        error_details = { type: 'population_sum', population_id: keys_and_ids[:pop_id],
                          stratification: stratification, expected_value: pop_sum, reported_value: sup_sum }
        options = { location: '/', measure_id: keys_and_ids[:measure_id], error_details: error_details, file_name: @file_name }
        add_error(err, options)
      end
    end

    def check_supplemental_data_expected_not_reported(expect_sup_val, report_sup_val, keys_and_ids, modified_population_labels, options)
      expect_sup_val.each_pair do |code, expect_val|
        report_val = get_translated_report_val(report_sup_val, code, keys_and_ids[:sup_key])
        next unless report_sup_val.nil? ||
                    ((code != 'UNK' && expect_val != report_val) &&
                     !CalculatingAugmentedResults.augmented_sup_val_expected?(options['task'], keys_and_ids, code,
                                                                              { expect: expect_val, report: report_val },
                                                                              modified_population_labels))

        report_val = report_sup_val.nil? ? 0 : report_sup_val[code]
        add_sup_data_error(keys_and_ids, code, expect_val, report_val)
      end
    end

    def get_translated_report_val(report_sup_val, code, sup_key)
      return nil if report_sup_val.nil?

      payer = APP_CONSTANTS['randomization']['payers'].find { |p| p['code'].to_s == code }
      code_cms = payer ? payer['codeCMS'] : ''
      return report_sup_val[code] if sup_key != 'PAYER' || !report_sup_val[code].nil? || report_sup_val[code_cms].nil?

      report_sup_val[code_cms]
    end

    def check_supplemental_data_reported_not_expected(expect_sup_val, report_sup_val, keys_and_ids, modified_population_labels, options)
      return if report_sup_val.nil?

      report_sup_val.each_pair do |code, report_val|
        code = get_untranslated_code(code, keys_and_ids[:sup_key])
        next unless report_val.positive? && expect_sup_val[code].nil? &&
                    !CalculatingAugmentedResults.augmented_sup_val_expected?(options['task'], keys_and_ids, code,
                                                                             { expect: expect_sup_val[code], report: report_val },
                                                                             modified_population_labels)

        add_sup_data_error(keys_and_ids, code, 0, report_val)
      end
    end

    def get_untranslated_code(code, sup_key)
      return code if sup_key != 'PAYER'

      payer = APP_CONSTANTS['randomization']['payers'].find { |p| p['codeCMS'].to_s == code }
      payer ? payer['code'].to_s : code
    end

    def add_sup_data_error(keys_and_ids, code, expect_val, report_val)
      error_details = { type: 'supplemental_data', population_key: keys_and_ids.pop_key,
                        population_id: keys_and_ids.pop_id, data_type: keys_and_ids.sup_key,
                        code: code, expected_value: expect_val, reported_value: report_val }
      options = { location: '/', measure_id: keys_and_ids.measure_id, error_details: error_details, file_name: @file_name }
      add_error('supplemental data error', options)
    end
  end
end
