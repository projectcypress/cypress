module Validators
  # This is a set of helper methods to assist in working with randomized
  # demographics on patients, so that the Expected Results Validator can
  # treat augmented calculation results as it would their originals.
  class CalculatingAugmentedRecords < CalculatingSmokingGunValidator
    def initialize(measures, records, test_id = 'testaugmented', options = {})
      super
    end

    # Functions related to individual record calculation results
    def parse_and_save_record(record)
      record.test_id = @test_id
      record.medical_record_number = rand(1_000_000_000_000_000)
      record.save
      record
    rescue
      nil
    end

    def validate_calculated_results(rec, options)
      mrn = rec.medical_record_number
      return false unless mrn

      passed = true
      record = parse_and_save_record(rec.clone)
      @bundle = ProductTest.find(record.test_id).bundle
      return false unless record
      @measures.each do |measure|
        ex_opts = { 'test_id' => record.test_id, 'bundle_id' => @bundle.id, 'effective_date' => options['effective_date'],
                    'enable_logging' => true, 'enable_rationale' => true, 'oid_dictionary' => generate_oid_dictionary(measure, @bundle.id) }
        @mre = QME::MapReduce::Executor.new(measure.hqmf_id, measure.sub_id, ex_opts)
        results = @mre.get_patient_result(record.medical_record_number)
        original_results = QME::PatientCache.where('value.medical_record_id' => mrn, 'value.test_id' => @test_id,
                                                   'value.measure_id' => measure.hqmf_id, 'value.sub_id' => measure.sub_id).first
        options[:population_ids] = measure.population_ids
        passed = compare_results(original_results, results, options, passed)
      end
      record.destroy
      passed
    end

    # Functions related to expected measure calculation results
    def self.augmented_sup_val_expected?(task, keys_and_ids, code, expect_report, mod_pop_labels)
      report_diff = (expect_report[:expect].nil? ? 0 : expect_report[:expect]) - (expect_report[:report].nil? ? 0 : expect_report[:report])
      expect_max_diff = 0
      key_to_field = { 'RACE' => :race, 'ETHNICITY' => :ethnicity, 'SEX' => :gender }

      task.augmented_records.each do |rec_changes|
        augmented_field = rec_changes[key_to_field[keys_and_ids[:sup_key]]]
        next unless augmented_record_in_population?(task, rec_changes, keys_and_ids, mod_pop_labels) &&
                    augmented_field && augmented_field[0] != augmented_field[1]
        if augmented_field[0] == code
          expect_max_diff += 1
        elsif augmented_field[1] == code
          expect_max_diff -= 1
        end
      end
      reported_in_expected_range?(report_diff, expect_max_diff)
    end

    def self.reported_in_expected_range?(report_diff, expect_max_diff)
      (report_diff <= 0 && report_diff >= expect_max_diff) || (report_diff >= 0 && report_diff <= expect_max_diff)
    end

    def self.augmented_record_in_population?(task, rec_changes, keys_and_ids, mod_pop_labels)
      ind = task.records.index { |r| r.medical_record_number == rec_changes.medical_record_number }
      task.records[ind].calculation_results.each do |calc_results|
        return true if calc_results.value[keys_and_ids[:pop_key]] || calc_results.value[mod_pop_labels.key(keys_and_ids[:pop_key])]
      end
      false
    end
  end
end
