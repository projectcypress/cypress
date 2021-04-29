# frozen_string_literal: true

module Cypress
  class ExamplePatientFinder
    # TODO: R2P: get sample patients (for checklist test) with new model

    def self.find_example_patient(measure)
      simplest = 100
      example_patient = nil
      # patient_ids for patients with IndividualResult for the measure specified
      patient_ids = IndividualResult.where(correlation_id: measure.bundle_id, measure_id: measure.id).pluck(:patient_id)
      CQM::Patient.find(patient_ids).each do |record|
        result_value = record.measure_relevance_hash[measure.id.to_s]

        count = population_matches_for_patient(result_value, measure)
        return record if [1, 2].include?(count)

        if count < simplest
          simplest = count
          example_patient = record
        end
      end
      example_patient
    end

    def self.population_matches_for_patient(result_value, measure)
      sum = 0
      populations = measure.measure_scoring == 'CONTINUOUS_VARIABLE' ? %w[IPP MSRPOPL MSRPOPLEX OBSERV] : %w[IPP DENOM NUMER DENEX DENEXCEP]
      populations.each do |pop|
        sum += 1 if result_value[pop]
      end
      sum
    end
  end
end
