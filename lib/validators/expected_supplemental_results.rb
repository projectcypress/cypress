# frozen_string_literal: true

module Validators
  # This is a set of helper methods to validate reported supplemental values associated
  # with a population key against reported ones.
  class ExpectedSupplementalResults < QrdaFileValidator
    include Validators::Validator

    def initialize(file_name)
      @file_name = file_name
      super()
    end

    def check_supplemental_data_matches_pop_sums(report_sup_val, keys_and_ids, expect_sup_val)
      pop_sum = expect_sup_val.values.reduce(:+) || 0
      sup_sum = 0
      report_sup_val&.each { |sup_set| sup_sum += sup_set[1] }
      return unless pop_sum != sup_sum

      err = %(Reported #{keys_and_ids[:pop_key]} value #{pop_sum} does not match \
sum #{sup_sum} of supplemental key #{keys_and_ids[:sup_key]} values)
      error_details = { type: 'population_sum', population_id: keys_and_ids[:pop_id],
                        stratification: keys_and_ids[:stratification_id], expected_value: pop_sum, reported_value: sup_sum }
      options = { location: '/', measure_id: keys_and_ids[:measure_id], error_details:, file_name: @file_name }
      add_error(err, options)
    end

    def check_supplemental_data_expected_not_reported(expect_sup_val, report_sup_val, keys_and_ids, randomization, options)
      expect_sup_val.each_pair do |code, expect_val|
        report_val = get_translated_report_val(report_sup_val, code, keys_and_ids[:sup_key], randomization)
        next unless report_sup_val.nil? ||
                    ((code != 'UNK' && expect_val != report_val) &&
                     !CalculatingAugmentedResults.augmented_sup_val_expected?(options['task'], keys_and_ids, code,
                                                                              expect: expect_val,
                                                                              report: report_val))

        report_val = report_sup_val.nil? ? 0 : report_sup_val[code]
        add_sup_data_error(keys_and_ids, code, expect_val, report_val)
      end
    end

    def get_translated_report_val(report_sup_val, code, sup_key, randomization)
      return nil if report_sup_val.nil?

      payer = randomization['payers'].find { |p| p['code'].to_s == code }
      code_cms = payer ? payer['codeCMS'] : ''
      return report_sup_val[code] if sup_key != 'PAYER' || !report_sup_val[code].nil? || report_sup_val[code_cms].nil?

      report_sup_val[code_cms]
    end

    def check_supplemental_data_reported_not_expected(expect_sup_val, report_sup_val, keys_and_ids, randomization, options)
      return if report_sup_val.nil?

      report_sup_val.each_pair do |code, report_val|
        codes = get_untranslated_code(code, keys_and_ids[:sup_key], randomization)
        found_match = codes.empty?
        codes.each do |c|
          found_match = true unless report_val.positive? && expect_sup_val[c].nil? &&
                                    !CalculatingAugmentedResults.augmented_sup_val_expected?(options['task'], keys_and_ids, c,
                                                                                             expect: expect_sup_val[c],
                                                                                             report: report_val)
        end
        add_sup_data_error(keys_and_ids, code, 0, report_val) unless found_match
      end
    end

    def get_untranslated_code(code, sup_key, randomization)
      return [code] if sup_key != 'PAYER'

      payers = randomization['payers'].select { |p| p['codeCMS'].to_s == code }
      payers ? payers.map { |payer| payer['code'].to_s } : [code]
    end

    def add_sup_data_error(keys_and_ids, code, expect_val, report_val)
      error_details = { type: 'supplemental_data', population_key: keys_and_ids.pop_key, data_type: keys_and_ids.sup_key,
                        population_id: keys_and_ids.pop_id, code:, expected_value: expect_val, reported_value: report_val }
      options = { location: '/', measure_id: keys_and_ids.measure_id, error_details:, file_name: @file_name }
      add_error('supplemental data error', options)
    end
  end
end
