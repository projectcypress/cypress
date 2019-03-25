Measure = CQM::Measure

module CQM
  class Measure
    store_in collection: 'measures'

    validates_inclusion_of :reporting_program_type, in: %w[ep eh]

    field :reporting_program_type, type: String
    field :category, type: String
    field :annual_update, type: String

    field :bundle_id, type: BSON::ObjectId

    def cms_int
      return 0 unless cms_id

      start_marker = 'CMS'
      end_marker = 'v'
      cms_id[/#{start_marker}(.*?)#{end_marker}/m, 1].to_i
    end

    # A measure may have 1 or more population sets that may have 1 or more stratifications
    # This method returns an array of hashes with the population_set and stratification_id for every combindation
    def population_sets_and_stratifications_for_measure
      population_set_array = []
      population_sets.each do |population_set|
        population_set_hash = { population_set_id: population_set.population_set_id }
        next if population_set_array.include? population_set_hash

        population_set_array << population_set_hash
        population_set.stratifications.each do |stratification|
          population_set_stratification_hash = { population_set_id: population_set.population_set_id,
                                                 stratification_id: stratification.stratification_id }
          population_set_array << population_set_stratification_hash
        end
      end
      population_set_array
    end

    # This method returns the population_set for a given 'population_set_key.'  The popluation_set_key is the key used
    # by the cqm-execution-service to reference the population set for a specific set of calculation results
    def population_set_for_key(population_set_key)
      ps_hash = population_sets_and_stratifications_for_measure
      ps_hash.keep_if { |ps| [ps[:population_set_id], ps[:stratification_id]].include? population_set_key }
      return nil if ps_hash.blank?

      [population_sets.where(population_set_id: ps_hash[0][:population_set_id]).first, ps_hash[0][:stratification_id]]
    end

    # This method returns an population_set_hash (from the population_sets_and_stratifications_for_measure)
    # for a given 'population_set_key.' The popluation_set_key is the key used by the cqm-execution-service
    # to reference the population set for a specific set of calculation results
    def population_set_hash_for_key(population_set_key)
      population_set_hash = population_sets_and_stratifications_for_measure
      population_set_hash.keep_if { |ps| [ps[:population_set_id], ps[:stratification_id]].include? population_set_key }.first
    end

    # This method returns a popluation_set_key for.a given population_set_hash
    def key_for_population_set(population_set_hash)
      population_set_hash[:stratification_id] || population_set_hash[:population_set_id]
    end

    # This method returns the subset of population keys used in a specific measure
    def population_keys
      %w[IPP DENOM NUMER NUMEX DENEX DENEXCEP MSRPOPL MSRPOPLEX].keep_if { |pop| population_sets.first.populations[pop]&.hqmf_id }
    end
  end
end
