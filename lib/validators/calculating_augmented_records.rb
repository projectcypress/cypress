module Validators
  # This is a set of helper methods to assist in working with randomized
  # demographics on patients, so that population results for an augmented
  # record can be compared to the results of the original.
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
  end
end
