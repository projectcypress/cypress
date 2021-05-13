# frozen_string_literal: true

IndividualResult = CQM::IndividualResult

module CQM
  class IndividualResult
    store_in collection: 'individual_results'

    field :population_set_key, type: String
    field :correlation_id, type: String
    field :file_name, type: String

    def observed_values
      return nil unless episode_results&.values&.any? { |er| er.key?('observation_values') }

      episode_results.values.map(&:observation_values)
    end

    def compare_results(calculated, options, previously_passed)
      issues = []
      if calculated.nil?
        [true && previously_passed, issues]
      else
        comp = true
        %w[IPP DENOM NUMER DENEX DENEXCEP MSRPOPL MSRPOPLEXCEP].each do |pop|
          original_value, calculated_value, pop = extract_calcuated_and_original_results(calculated, pop)
          next unless original_value != calculated_value

          pop_statement = options[:population_set].populations[pop].hqmf_id
          pop_statement << " Stratification #{options[:stratification_id]}" if options[:stratification_id]
          issues << "Calculated value (#{calculated_value}) for #{pop} (#{pop_statement}) does not match expected value (#{original_value})"
          comp = false
        end
        APP_CONSTANTS['result_measures'].each do |result_measure|
          compare_statement_results(calculated, result_measure['statement_name'], issues) if measure.hqmf_set_id == result_measure['hqmf_set_id']
        end
        compare_observations(calculated, issues) if observed_values
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

    def compare_observations(calculated, issues = [])
      calculated_er = calculated['episode_results'].values.map(&:observation_values).sort
      expected_er = episode_results.values.map(&:observation_values).sort

      return unless calculated_er != expected_er

      issues << "Calculated observations (#{calculated_er}) do not match "\
                "expected observations (#{expected_er})"
    end

    # adds the observation values found in an individual_result to the observation_hash
    # Set agg_results to true if you are collecting aggregate results for multiple patients
    #
    # Below is an example hash for an individual (the hash key is the patient id)
    # {BSON::ObjectId('60806298c1c388315523be47')=>{"IPP"=>{:values=>[]},
    # "MSRPOPL"=>{:values=>[{:episode_index=>0, :value=>75}, {:episode_index=>1, :value=>50}], :statement_name=>"Measure Population"},
    # "MSRPOPLEX"=>{:values=>[]}}}

    # Below is an example hash for aggregate results (the hash keys are the population set keys)
    # {"PopulationSet_1"=>{"IPP"=>{:values=>[]},
    # "DENOM"=>{:values=>[{:episode_index=>0, :value=>9}, {:episode_index=>0, :value=>2}, :statement_name=>"Denominator"},
    # "NUMER"=>{:values=>[]}}}
    def collect_observations(observation_hash = {}, agg_results: false)
      return unless episode_results

      key = agg_results ? population_set_key : patient_id
      setup_observation_hash(observation_hash, key)
      population_set = measure.population_set_for_key(population_set_key).first
      # collect the observation_statements for the population_set. There may be more than one. episode_results are recorded in the same order
      observation_statements = population_set.observations.map { |obs| obs.observation_parameter.statement_name }
      # collect the observation_values from and individual_result
      # a scenario with multiple episodes and multiple observations would look like this [[2], [9, 1]]
      observation_values = get_observ_values(episode_results).compact
      observation_values.each_with_index do |observation_value, episode_index|
        observation_value.each_with_index do |observation, index|
          # lookup the population code (e.g., DENOM is the population code for the statement named 'Denominator')
          obs_pop = measure.population_keys.find { |pop| population_set.populations[pop]['statement_name'] == observation_statements[index] }
          # add the observation to the hash
          observation_hash[key][obs_pop][:values] << { episode_index: episode_index, value: observation }
          observation_hash[key][obs_pop][:statement_name] = observation_statements[index]
        end
      end
      observation_hash
    end

    def setup_observation_hash(observation_hash, key)
      observation_hash[key] = {} unless observation_hash[key]
      measure.population_keys.each do |pop|
        observation_hash[key][pop] = { values: [] } unless observation_hash[key][pop]
      end
    end

    def get_observ_values(episode_results)
      episode_results.collect do |_id, episode_result|
        # Only use observed values when a patient is in the MSRPOPL and not in the MSRPOPLEX
        next unless (episode_result['MSRPOPL']&.positive? && !episode_result['MSRPOPLEX']&.positive?) || episode_result['MSRPOPL'].nil?

        episode_result['observation_values']
      end
    end

    def compare_statement_results(calculated, statement_name, issues = [])
      combined_statement_results = gather_statement_results(calculated, statement_name)
      combined_statement_results.each do |csr|
        # if original and reported match, move on
        next unless csr[:original] != csr[:reported]

        # if the original value is nil, and a value is reported, return error message
        if csr[:original].nil?
          issues << "#{csr[:name]} not expected"
          next
        end
        issues << if csr[:reported].nil?
                    "#{csr[:name]} of #{csr[:original]['value']} #{csr[:original]['unit']} is missing"
                  else
                    "#{csr[:name]} of #{csr[:original]['value']} #{csr[:original]['unit']} does not match "\
                    "#{csr[:reported]['value']} #{csr[:reported]['unit']}"
                  end
      end
    end

    # Helper method that compiles an array with the orignial and reported value for each result type.
    def gather_statement_results(calculated, statement_name)
      return [] if statement_results.blank?

      original_statement_results = statement_results.select { |sr| sr['statement_name'] == statement_name }.first['raw']
      calculated_statement_results = calculated['statement_results'].select { |sr| sr['statement_name'] == statement_name }.first['raw']
      combined_statement_results = []
      original_statement_results.each do |result_name, value|
        next if calculated_statement_results[result_name].empty?

        statement_result_hash = { name: result_name,
                                  original: value.first['FirstResult'],
                                  reported: calculated_statement_results[result_name].first['FirstResult'] }
        combined_statement_results << statement_result_hash
      end
      combined_statement_results
    end
  end
end
