# frozen_string_literal: true

IndividualResult = CQM::IndividualResult

module CQM
  class IndividualResult
    store_in collection: 'individual_results'

    field :population_set_key, type: String
    field :correlation_id, type: String
    field :file_name, type: String

    # Recalculates Individual Result and saves the clause_results
    def recalculate_with_highlighting
      # Use the bundle of product test to find measure_period_start
      measure_period_start = if patient.is_a? CQM::ProductTestPatient
                               patient.product_test.measure_period_start
                             else
                               patient.bundle.measure_period_start
                             end
      options = { 'effectiveDate' => Time.at(measure_period_start).in_time_zone.to_formatted_s(:number),
                  'includeClauseResults' => true }
      calc_job = Cypress::CQMExecutionCalc.new([patient.qdmPatient],
                                               [measure],
                                               correlation_id,
                                               options)
      new_results = calc_job.execute(save: false)
      new_results.each do |new_result|
        next unless population_set_key == new_result['population_set_key']

        self.clause_results = new_result['clause_results']
        save
      end
    end

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
          # CQL requires a minimum of 8 decimal values.  Cap our check there.
          next unless original_value.round(8) != calculated_value.round(8)

          pop_statement = options[:population_set].populations[pop].hqmf_id
          pop_statement << " Stratification #{options[:stratification_id]}" if options[:stratification_id]
          issues << "Calculated value (#{calculated_value}) for #{pop} (#{pop_statement}) does not match expected value (#{original_value})"
          comp = false
        end
        compare_sde_results(calculated, issues)
        compare_observations(calculated, issues) if observed_values
        [previously_passed && comp, issues]
      end
    end

    def compare_sde_results(calculated, issues)
      APP_CONSTANTS['result_measures'].each do |result_measure|
        compare_statement_results(calculated, result_measure['statement_name'], issues) if measure.hqmf_id == result_measure['hqmf_id']
      end
      APP_CONSTANTS['risk_variable_measures'].each do |risk_variable_measure|
        compare_risk_variable_results(calculated, issues) if measure.hqmf_id == risk_variable_measure['hqmf_id']
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
      # If there aren't any calculated episode_results, use an empty array for comparison
      calculated_er = calculated['episode_results'] ? calculated['episode_results'].values.map(&:observation_values).sort : []
      expected_er = episode_results.values.map(&:observation_values).sort

      return unless calculated_er != expected_er

      issues << "Calculated observations (#{calculated_er}) do not match " \
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
          # The Index of the Population Set ('Population Criteria 1')
          popset_index = measure.population_sets_and_stratifications_for_measure.find_index do |pop_set|
            pop_set[:population_set_id] == population_set[:population_set_id]
          end

          # Skip recording observations that are for a different population set.
          # This will occur when all of the observation_statements are for the same population (e.g., 'MSRPOPL')
          # And when the index of the observation does not match the index of the population set
          next if observation_statements.uniq.size == 1 && index != popset_index

          # add the observation to the hash
          observation_hash[key][obs_pop][:values] << { episode_index:, value: observation }
          observation_hash[key][obs_pop][:statement_name] = observation_statements[index]
        end
      end
      observation_hash
    end

    # Risk_variables statement results can be an array of encounters that include the risk variable or a hash of named values
    # For example, a raw result for an encounter array will look like
    # { 'raw' => [{ '_type' => 'QDM::EncounterPerformed',
    #               'qdmTitle' => 'Encounter, Performed',
    #               'id' => '627562c2c1c388f89d2ab681' }],
    #            'statement_name' => 'Risk Variable Asthma' }
    # a raw result for an encounter with results will look like
    # { 'raw' => { 'FirstHeartRate' =>
    #                 [{ 'EncounterId' => '627562f5c1c388f89d2ac2f9',
    #                    'FirstResult' => { 'value' => 65, 'unit' => '/min' },
    #                    'Timing' => '2021-06-15T05:00:00.000+00:00' }] },
    #              'statement_name' => 'Risk Variable Anemia' }]
    # collect_risk_variables returns a hash of values organized by statement name and encounter id.
    def collect_risk_variables
      risk_variable_hash = {}
      measure.supplemental_data_elements.each do |supplemental_data_element|
        statement_name = supplemental_data_element['statement_name']
        raw_results = statement_results.select { |sr| sr['statement_name'] == statement_name }.first&.raw
        risk_variable_values = {}
        case raw_results
        when Array
          risk_variable_from_array(risk_variable_values, raw_results)
        when Hash
          risk_variable_from_hash(risk_variable_values, raw_results)
        end
        risk_variable_hash[statement_name] = { values: risk_variable_values }
      end
      risk_variable_hash
    end

    def risk_variable_from_array(risk_variable_values, raw_results)
      encounter_id = nil
      raw_results.flatten.each do |rv_value|
        next unless rv_value

        encounter_id = rv_value['id'] if (rv_value.is_a? Hash) && rv_value['qdmTitle'] == 'Encounter, Performed'
        # TODO: better support for CMS832
        if encounter_id.nil?
          risk_variable_values['Other'] = raw_results
        else
          risk_variable_values[encounter_id] = if rv_value.is_a? Hash
                                                 rv_value['qdmTitle']
                                               else
                                                 rv_value
                                               end
        end
      end
    end

    def risk_variable_from_hash(risk_variable_values, raw_results)
      encounter_value_hash = {}
      raw_results.each do |key, rv_values|
        # TODO:  Need a better way to deal with the different way risk variables are reported in the eCQMs
        next unless rv_values.is_a?(Array)

        rv_values.each do |rv_value|
          encounter_value_hash[rv_value['EncounterId']] = {} unless encounter_value_hash[rv_value['EncounterId']]
          next unless rv_value['FirstResult']

          encounter_value_hash[rv_value['EncounterId']][key] = "#{rv_value['FirstResult']['value']} #{rv_value['FirstResult']['unit']}"
        end
      end
      encounter_value_hash.each do |encounter_key, values|
        risk_variable_values[encounter_key] = values
      end
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
        if csr[:original].nil? || csr[:original].empty?
          issues << "#{csr[:name]} not expected"
          next
        end
        issues << if csr[:reported].nil? || csr[:reported].empty?
                    original_vals = csr[:original].map { |o| "#{o['value']} #{o['unit']}" }.join(', ')
                    "#{csr[:name]} of [#{original_vals}] is missing"
                  else
                    reported_vals = csr[:reported].map { |r| "#{r['value']} #{r['unit']}" }.join(', ')
                    original_vals = csr[:original].map { |o| "#{o['value']} #{o['unit']}" }.join(', ')
                    "#{csr[:name]} of [#{original_vals}] does not match [#{reported_vals}]"
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

        original_values = value.map(&:FirstResult).compact.empty? ? [] : value.map(&:FirstResult).compact&.sort_by! { |fr| fr['value'] }
        calculated_values = calculated_statement_results[result_name].map(&:FirstResult).compact&.sort_by! { |fr| fr['value'] }
        statement_result_hash = { name: result_name,
                                  original: values_without_annotations(original_values),
                                  reported: values_without_annotations(calculated_values) }
        combined_statement_results << statement_result_hash
      end
      combined_statement_results
    end

    # remove all annotations from values using brackets {}
    def values_without_annotations(values)
      values.each { |val| val['unit'] = val['unit']&.gsub(/{.*?}/, '') }
    end

    def hash_values_match?(hash1, hash2)
      # Match is false if hash2 is nil
      return false if hash1 && hash2.nil?

      # If hash2 has more values than hash1, more details are being provided, which is ok
      hash1.values.compact.size <= hash2.values.compact.size
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # Returns an issue when expected risk variables are missing.  Does not validate the content of the returned risk variables, just existence.
    def compare_risk_variable_results(calculated, issues = [])
      measure.supplemental_data_elements.each do |supplemental_data_element|
        statement_name = supplemental_data_element['statement_name']
        original_statement_results = statement_results.select { |sr| sr['statement_name'] == statement_name }.first&.raw
        calculated_statement_results = calculated['statement_results'].select { |sr| sr['statement_name'] == statement_name }.first&.raw

        statements_match = true
        case original_statement_results
        when Array
          # Are the result arrays the same length
          statements_match = original_statement_results&.size == calculated_statement_results&.size
          original_statement_results.each_with_index do |original_statement_result, index|
            # Skip check if an unmatched results is already found
            next unless statements_match
            # If the statement isn't a hash, move on
            next unless original_statement_result.is_a? Hash

            # check if the hash's contain the same number of result values
            statements_match = hash_values_match?(original_statement_result, calculated_statement_results[index])
          end
        when Hash
          # check if the hash's contain the same number of result values
          statements_match = hash_values_match?(original_statement_results, calculated_statement_results)
        end

        issues << "#{statement_name} - Not Found in File" unless statements_match
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
