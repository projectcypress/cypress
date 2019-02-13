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

    def population_set_identifiers
      population_set_names = population_sets.collect(&:population_set_id)
      population_set_names.concat population_sets.collect(&:stratifications).flatten.collect(&:stratification_id)
    end

    def hqmf_ids_for_population_set(population_set)
      measure_populations = %w[DENOM NUMER DENEX DENEXCEP IPP MSRPOPL MSRPOPLEX]
      pop_suffix = ''
      population_id_hash = {}
      if !population_sets.where(population_set_id: population_set).empty?
        pop_suffix = population_id_hash_for_population_set(population_set, population_id_hash)
      elsif !population_sets.where('stratifications.stratification_id': population_set).empty?
        pop_suffix = population_id_hash_for_stratification(population_set, population_id_hash)
      end
      measure_populations.each do |pop|
        population_id_hash[pop] = population_criteria["#{pop}#{pop_suffix}"]['hqmf_id'] if population_criteria["#{pop}#{pop_suffix}"]
      end
      population_id_hash
    end

    private

    def population_id_hash_for_population_set(population_set, population_id_hash)
      pop_set = population_sets.where(population_set_id: population_set).first
      pop_index = population_sets.distinct(:population_set_id).find_index(pop_set.population_set_id)
      pop_suffix = "_#{pop_index}" unless pop_index.zero?
      population_id_hash['OBSERV'] = population_criteria['OBSERV']['hqmf_id'] if pop_set.observations
      pop_suffix
    end

    def population_id_hash_for_stratification(population_set, population_id_hash)
      strat_suffix = ''
      pop_set = population_sets.where('stratifications.stratification_id': population_set).first
      pop_index = population_sets.distinct(:population_set_id).find_index(pop_set.population_set_id)
      strat_index = population_sets.distinct(:stratifications).flatten.map(&:stratification_id).find_index(population_set)
      pop_suffix = "_#{pop_index}" unless pop_index.zero?
      strat_suffix = "_#{strat_index}" unless strat_index.zero?
      population_id_hash['OBSERV'] = population_criteria['OBSERV']['hqmf_id'] if pop_set.observations
      population_id_hash['STRAT'] = population_criteria["STRAT#{strat_suffix}"]['hqmf_id'] if population_criteria["STRAT#{strat_suffix}"]
      pop_suffix
    end
  end
end
