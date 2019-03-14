module Validators
  # This is a set of helper methods to assist in working with randomized
  # demographics on patients, so that population results for an augmented
  # record can be compared to the results of the original.
  class CalculatingAugmentedRecords < CalculatingSmokingGunValidator
    def initialize(measures, records, test_id = 'testaugmented', options = {})
      super
    end

    # Functions related to individual record calculation results
    def parse_record(record)
      record.correlation_id = @test_id
      record.medical_record_number = rand(1_000_000_000_000_000)
      record
    rescue
      nil
    end

    # create a temporary record copy to do calculations on
    def validate_calculated_results(rec, options)
      # return false unless mrn
      record = parse_record(rec.clone)
      product_test = ProductTest.find(record.correlation_id)
      return false unless record

      calc_job = Cypress::CqmExecutionCalc.new([record.qdmPatient], product_test.measures, nil,
                                               'effectiveDateEnd': Time.at(product_test.effective_date).in_time_zone.to_formatted_s(:number),
                                               'effectiveDate': Time.at(product_test.measure_period_start).in_time_zone.to_formatted_s(:number))
      results = calc_job.execute(false)
      passed = compare_results(results, record, options)
      passed
    end

    def compare_results(results, record, options)
      passed = true
      @measures.each do |measure|
        # compare results to patient as it was initially calculated for product test (use original product patient id before cloning)
        orig_results = IndividualResult.where('patient_id': options[:orig_product_patient].id, 'measure_id': measure.id)
        orig_results.each do |orig_result|
          new_result = results.select do |arr|
            arr.measure_id == measure.id.to_s &&
              arr.patient_id == record.id.to_s &&
              arr.population_set_key == orig_result['population_set_key']
          end.first
          measure.population_keys.each do |pop_id|
            if orig_result[pop_id] != new_result[pop_id]
              passed = false
              break
            end
          end
        end
      end
      passed
    end
  end
end
