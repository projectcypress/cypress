IndividualResult = CQM::IndividualResult

module CQM
  class IndividualResult
    store_in collection: 'individual_results'

    field :population_set_key, type: String
    field :correlation_id, type: String
    field :file_name, type: String

    def compare_results(calculated, options, previously_passed)
      issues = []
      if calculated.nil?
        [true && previously_passed, issues]
      else
        comp = true
        %w[IPP DENOM NUMER DENEX DENEXCEP MSRPOPL MSRPOPLEXCEP values].each do |pop|
          original_value, calculated_value, pop = extract_calcuated_and_original_results(calculated, pop)
          next unless original_value != calculated_value

          pop_statment = options[:population_set].populations[pop].hqmf_id
          pop_statment << " Stratification #{options[:stratification_id]}" if options[:stratification_id]
          issues << "Calculated value (#{calculated_value}) for #{pop} (#{pop_statment}) does not match expected value (#{original_value})"
          comp = false
        end
        APP_CONSTANTS['result_measures'].each do |result_measure|
          compare_statement_results(calculated, result_measure['statement_name'], issues) if measure.hqmf_set_id == result_measure['hqmf_set_id']
        end
        [previously_passed && comp, issues]
      end
    end

    def extract_calcuated_and_original_results(calculated, pop)
      # set original value to 0 if it wasn't calculated
      original_value = self[pop].nil? ? 0.0 : self[pop]
      # set calculated value to 0 if there is no calculation for the measure or population
      calculated_value = calculated.nil? || calculated[pop].nil? ? 0.0 : calculated[pop]
      if pop == 'values'
        pop = 'OBSERV'
        # the orginal and calculated values should be an array make empty if it doesn't exist
        original_value = [] unless original_value.is_a?(Array)
        calculated_value = [] if calculated_value.nil? || !calculated_value.is_a?(Array)
      end
      [original_value, calculated_value, pop]
    end

    def compare_statement_results(calculated, statement_name, issues = [])
      statement_results = gather_statement_results(calculated, statement_name)
      statement_results.each do |statement_result|
        # if original and reported match, move on
        next unless statement_result[:original] != statement_result[:reported]

        # if the original value is nil, and a value is reported, return error message
        if statement_result[:original].nil?
          issues << "#{statement_result[:name]} not expected"
          next
        end
        issues << if statement_result[:reported].nil?
                    "#{statement_result[:name]} of #{statement_result[:original]['value']} #{statement_result[:original]['unit']} is missing"
                  else
                    "#{statement_result[:name]} of #{statement_result[:original]['value']} #{statement_result[:original]['unit']} does not match "\
                    "#{statement_result[:reported]['value']} #{statement_result[:reported]['unit']}"
                  end
      end
    end

    # Helper method that compiles an array with the orignial and reported value for each result type.
    def gather_statement_results(calculated, statement_name)
      original_statement_results = statement_results.select { |sr| sr['statement_name'] == statement_name }.first['raw']
      calculated_statement_results = calculated['statement_results'].select { |sr| sr['statement_name'] == statement_name }.first['raw']
      statement_results = []
      original_statement_results.each do |result_name, value|
        statement_result_hash = { name: result_name,
                                  original: value.first['FirstResult'],
                                  reported: calculated_statement_results[result_name].first['FirstResult'] }
        statement_results << statement_result_hash
      end
      statement_results
    end
  end
end
