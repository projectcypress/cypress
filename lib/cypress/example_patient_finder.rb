module Cypress
  class ExamplePatientFinder
    def self.find_example_patient(measure)
      measure = Measure.find_by name: measure.name
      records = Bundle.default.records
      lowest = 100
      example = nil
      records.each do |patient|
        result_value = patient.calculation_results.where('value.measure_id' => measure.hqmf_id).where('value.sub_id' => measure.sub_id)
        match_ipp = get_result_value(result_value, 'IPP')
        next unless match_ipp && match_ipp > 0
        count = population_matches_for_patient(result_value, measure)
        return patient if count == 1
        if count < lowest
          lowest = count
          example = patient
        end
      end
      example
    end

    def self.get_result_value(result_value, population)
      result_value.first.value[population].to_i if result_value.first
    end

    def self.population_matches_for_patient(result_value, measure)
      sum = 0
      populations = measure.continuous_variable ? %w(IPP MSRPOPL MSRPOPLEX OBSERV) : %w(IPP DENOM NUMER DENEX DENEXCEP)
      populations.each do |pop|
        value = get_result_value(result_value, pop)
        sum += value unless value.nil?
      end
      sum
    end
  end
end
