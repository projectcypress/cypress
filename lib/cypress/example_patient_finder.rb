module Cypress
  class ExamplePatientFinder
    # TODO: R2P: get sample patients (for checklist test) with new model

    def self.find_example_patient(measure)
      populations = measure.measure_scoring == 'CONTINUOUS_VARIABLE' ? %w[IPP MSRPOPL MSRPOPLEX OBSERV] : %w[IPP DENOM NUMER DENEX DENEXCEP]
      example_patient = example_patient_by_pop(measure, populations, populations[1])
      example_patient = !example_patient.nil? ? example_patient : example_patient_by_pop(measure, populations, 'IPP')
      # if you still don't have a patient, find one from sub population a
      !example_patient.nil? ? example_patient : example_patient_by_pop((Measure.find_by description: measure.description), populations, 'IPP')
    end

    def self.example_patient_by_pop(measure, _populations, pop)
      simplest = 100
      example_patient = nil
      patient_ids = IndividualResult.where(correlation_id: measure.bundle_id, measure_id: measure.id).pluck(:patient_id)
      CQM::Patient.find(patient_ids).each do |record|
        result_value = record.calculation_results.where(measure_id: measure.id).only(:IPP, :DENOM, :NUMER, :NUMEX, :DENEX,
                                                                                     :DENEXCEP, :MSRPOPL, :OBSERV, :MSRPOPLEX)
        next unless get_result_value(result_value, pop)

        count = population_matches_for_patient(result_value, measure)
        return record if [1, 2].include?(count)

        if count < simplest
          simplest = count
          example_patient = record
        end
      end
      example_patient
    end

    def self.get_result_value(result_value, population)
      result_value.first[population] if result_value.first
    end

    def self.population_matches_for_patient(result_value, measure)
      sum = 0
      populations = measure.measure_scoring == 'CONTINUOUS_VARIABLE' ? %w[IPP MSRPOPL MSRPOPLEX OBSERV] : %w[IPP DENOM NUMER DENEX DENEXCEP]
      populations.each do |pop|
        value = get_result_value(result_value, pop)
        sum += 1 if value
      end
      sum
    end
  end
end
