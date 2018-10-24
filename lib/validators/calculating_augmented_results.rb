module Validators
  # This is a set of helper methods to assist in working with randomized
  # demographics on patients, so that the Expected Results Validator can
  # treat augmented calculation results as it would their originals.
  class CalculatingAugmentedResults
    def self.augmented_sup_val_expected?(task, keys_and_ids, code, expect_report, mod_pop_labels)
      report_diff = (expect_report[:expect].nil? ? 0 : expect_report[:expect]) - (expect_report[:report].nil? ? 0 : expect_report[:report])
      # expect_diff [min, max]
      expect_diff = [0, 0]
      key_to_field = { 'RACE' => :race, 'ETHNICITY' => :ethnicity, 'SEX' => :gender }

      task.augmented_patients.each do |rec_changes|
        augmented_field = rec_changes[key_to_field[keys_and_ids[:sup_key]]]
        next unless augmented_record_in_population?(task, rec_changes, keys_and_ids, mod_pop_labels) &&
                    augmented_field && augmented_field[0] != augmented_field[1]

        if augmented_field[0] == code
          expect_diff[1] += 1
        elsif augmented_field[1] == code
          expect_diff[0] -= 1
        end
      end
      reported_in_expected_range?(report_diff, expect_diff)
    end

    def self.reported_in_expected_range?(report_diff, expect_diff)
      # If reported diff is negative, compare with min diff, if reported diff is positive, compare with max diff
      (report_diff <= 0 && report_diff >= expect_diff[0]) || (report_diff >= 0 && report_diff <= expect_diff[1])
    end

    def self.augmented_record_in_population?(task, rec_changes, keys_and_ids, mod_pop_labels)
      ind = task.patients.index { |r| r.id == rec_changes['original_patient_id'] }
      task.patients[ind].calculation_results.each do |calc_results|
        return true if calc_results[keys_and_ids[:pop_key]] || calc_results[mod_pop_labels.key(keys_and_ids[:pop_key])]
      end
      false
    end
  end
end
