class MeasureEvaluationJob < ApplicationJob
  queue_as :default
  include Job::Status

  # The MeasureEvaluationJob aggregates Individual Results to calculated the expected results for a
  # Measure Test
  #
  # @param [Object] product_test The ProductTest being evalutated
  # @return none
  def perform(product_test)
    product_test.measures.each do |measure|
      ar = ProductTestAggregateResult.create(product_test: product_test, measure_id: measure.id)
      IndividualResult.where(correlation_id: product_test.id.to_s).each do |individual_result|
        ar.add_individual_result(individual_result)
      end
      account_for_augmented_records(ar)
      account_for_population_sets(ar, measure)
      ar.save
    end
  end

  def setup_demographics_codes
    @demographic_type_hash = { 'F' => 'SEX', 'M' => 'SEX' }
    @demographic_type_hash.merge!(APP_CONSTANTS['randomization']['races'].map(&:code).map { |code| [code, 'RACE'] }.to_h)
    @demographic_type_hash.merge!(APP_CONSTANTS['randomization']['ethnicities'].map(&:code).map { |code| [code, 'ETHNICITY'] }.to_h)
  end

  def account_for_population_sets(aggregate_result, measure)
    measure.population_sets_and_stratifications_for_measure.each do |psh|
      aggregate_result.population_set_results.find_or_create_by(population_set_id: psh[:population_set_id],
                                                                stratification_id: psh[:stratification_id])
    end
  end

  def account_for_augmented_records(aggregate_result)
    setup_demographics_codes
    aggregate_result.product_test.augmented_patients.each do |augmented_patient|
      next if augmented_patient[:gender].nil? && augmented_patient[:race].nil? && augmented_patient[:ethnicity].nil?

      increment_up_codes, increment_down_codes = increment_up_and_down_codes(augmented_patient)
      calculation_results = IndividualResult.where(patient_id: augmented_patient[:original_patient_id])
      calculation_results.each do |calculation_result|
        psk = calculation_result.population_set_key
        population_set_result = aggregate_result.population_set_results.select { |ps| ps.population_set_key == psk }.first
        next if population_set_result.stratification_id

        update_acceptable_patient_count(population_set_result,
                                        calculation_result.measure.population_keys,
                                        increment_up_codes,
                                        increment_down_codes)
      end
    end
  end

  def update_acceptable_patient_count(population_set_result, populations, increment_up_codes, increment_down_codes)
    downs = population_set_result.get_supplemental_information(populations, increment_down_codes)
    ups = compile_up_codes(population_set_result, populations, increment_up_codes)

    ups.each do |up|
      up.acceptable_patient_count << up.patient_count if up.acceptable_patient_count.empty?
      up.acceptable_patient_count << up.acceptable_patient_count.max + 1
    end
    downs.each do |down|
      down.acceptable_patient_count << down.patient_count if down.acceptable_patient_count.empty?
      down.acceptable_patient_count << down.acceptable_patient_count.min - 1
    end
  end

  def compile_up_codes(population_set_result, populations, increment_up_codes)
    ups = []
    populations.each do |population|
      increment_up_codes.each do |code|
        existing_ups = population_set_result.get_supplemental_information([population], [code])
        if existing_ups.blank?
          up = population_set_result.supplemental_information.find_or_create_by(key: @demographic_type_hash[code], population: population, code: code)
          ups << up
        else
          ups.concat(existing_ups)
        end
      end
    end
    ups
  end

  def increment_up_and_down_codes(augmented_patient)
    up_codes = []
    down_codes = []
    demographics = %i[gender race ethnicity]
    demographics.each do |demographic|
      next unless augmented_patient[demographic]
      next if augmented_patient[demographic][0] == augmented_patient[demographic][1]

      up_codes << augmented_patient[demographic][1]
      down_codes << augmented_patient[demographic][0]
    end
    [up_codes, down_codes]
  end
end
