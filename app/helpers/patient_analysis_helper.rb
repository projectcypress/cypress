# frozen_string_literal: true

module PatientAnalysisHelper
  def collate_vs_info(codes_found, value_sets_found, vs_codes_found)
    codes_found.each do |dec|
      # find all valuesets that contain data element code
      vs = ValueSet.where('concepts.code' => dec.code).map { |vset| vset.id.to_s }
      value_sets_found.merge(vs)
      vs.each do |id|
        vs_codes_found[id] = Set[] unless vs_codes_found.key?(id)
        vs_codes_found[id].add(dec.code)
      end
    end
  end

  def collate_patient_data
    measures_found = Set[]
    codes_found = Set[]
    de_types_found = Set[]
    value_sets_found = Set[]
    vs_codes_found = {}

    @patients.each do |p|
      measures_found.merge(p.measure_relevance_hash.keys)
      p.qdmPatient.dataElements.each { |de| de_types_found.add(de._type) }
      codes_found.merge(p.code_description_hash.keys.map { |cdh| { code: cdh.split(':')[0].tr('_', '.'), system: cdh.split(':')[1].tr('_', '.') } })
    end
    collate_vs_info(codes_found, value_sets_found, vs_codes_found)
    [measures_found, de_types_found, value_sets_found, vs_codes_found]
  end

  def ignore_clause_result(clause)
    # Ignore value set clauses and Ignore clauses that were not used in logic, for example unused defines from an included library
    (clause&.raw.respond_to?('name') && clause.raw.name == 'ValueSet') || clause.final == 'NA'
  end

  def generate_coverage_summary(measures)
    un_hit_populations = collate_possible_measure_populations(measures)
    possible_populations_count = un_hit_populations.values.flatten.size
    possible_clauses = collate_possible_clauses(measures)
    un_hit_clauses = possible_clauses.clone
    measures.each do |measure|
      IndividualResult.where(correlation_id: @patients.first.correlation_id.to_s, measure_id: measure).each do |ir|
        remove_hit_populations(ir, un_hit_populations) unless un_hit_populations[measure].empty?
        next if un_hit_clauses[measure].empty?

        hit_clauses = ir.clause_results.where(final: 'TRUE').map { |cl| "#{cl.library_name}_#{cl.localId}" }
        un_hit_clauses[measure] -= hit_clauses
      end
    end
    collate_coverage_summaries(measures, possible_clauses, un_hit_clauses, possible_populations_count, un_hit_populations)
  end

  def remove_hit_populations(individual_result, un_hit_populations)
    individual_result.measure.population_keys.each do |pop_key|
      measure_id = individual_result.measure.id.to_s
      un_hit_populations[measure_id].delete("#{individual_result['population_set_key']}|#{pop_key}") if individual_result[pop_key]&.positive?
    end
  end

  def collate_possible_measure_populations(measures)
    possible_populations = {}
    measures.each do |m|
      measure = Measure.find(m)
      possible_populations[m] = measure.population_sets_and_stratifications_for_measure.map do |ps_s_m|
        pops = measure.population_sets.where(population_set_id: ps_s_m.population_set_id).first.populations
        measure.population_keys.map { |pk| "#{measure.key_for_population_set(ps_s_m)}|#{pk}" if pops[pk] }.compact.flatten
      end.flatten
    end
    possible_populations
  end

  def collate_possible_clauses(measures)
    possible_clauses = {}
    measures.each do |measure_id|
      possible_clauses[measure_id] = []
      # BSON::ObjectId(measure)
      measure = Measure.find(measure_id)
      ps_set_hashes = measure.population_sets_and_stratifications_for_measure
      ps_set_hashes.each do |ps_set_hash|
        ir_for_population_set_key = IndividualResult.where(correlation_id: @patients.first.correlation_id.to_s,
                                                           measure_id:,
                                                           population_set_key: measure.key_for_population_set(ps_set_hash))
        next if ir_for_population_set_key.empty?

        clauses = ir_for_population_set_key.first.clause_results
        clauses.each do |clause|
          next if ignore_clause_result(clause)

          key = "#{clause.library_name}_#{clause.localId}"
          possible_clauses[measure_id] << key
        end
      end
      possible_clauses[measure_id] = possible_clauses[measure_id].uniq
    end
    possible_clauses
  end

  def collate_coverage_summaries(measures, possible_clauses, un_hit_clauses, possible_populations_count, un_hit_populations)
    clause_coverage_summaries = {}
    measures.each do |measure_id|
      hit_clauses = possible_clauses[measure_id].size - un_hit_clauses[measure_id].size
      percent_covered = hit_clauses.fdiv(possible_clauses[measure_id].size)
      clause_coverage_summaries[Measure.find(measure_id).cms_id] = percent_covered
    end
    population_coverage_summaries = {}
    total_hit_populations = possible_populations_count - un_hit_populations.values.flatten.size
    population_coverage_summaries['total_population_coverage'] = total_hit_populations.fdiv(possible_populations_count)
    population_coverage_summaries['unhit_populations_by_measure'] = un_hit_populations
    [clause_coverage_summaries, population_coverage_summaries]
  end

  def collate_vs_code_sys(value_sets_found)
    vs_code_sys_found = {}
    value_sets_found.each do |vs|
      vs_code_sys_found[vs] = Set[]
      ValueSet.find(vs).concepts.each do |concept|
        vs_code_sys_found[vs].add(concept.code_system_oid)
      end
    end
    vs_code_sys_found
  end

  def basic_analysis(relevant_measures, measures_found, de_types_found, value_sets_found)
    analysis = {}
    analysis['patient_count'] = @patients.count
    analysis['measures_found'] = measures_found.count.to_i
    analysis['relevant_measures'] = relevant_measures.count
    analysis['measure_coverage'] = measures_found.count.to_f / relevant_measures.count
    analysis['data_element_types'] = de_types_found.count
    analysis['value_sets'] = value_sets_found.count
    analysis
  end

  def all_valuesets(relevant_measures)
    total_vs = Set[]
    relevant_measures.each do |m|
      measure_valuesets = ValueSet.find(m.value_set_ids)
      total_vs.merge(measure_valuesets.map { |vs| vs.id.to_s })
    end
    total_vs
  end

  def per_vs_stats(total_vs, total_vs_code_sys, total_vs_codes, vs_codes_found, percent_vs_codes)
    total_vs.each do |vs|
      total_vs_code_sys[vs] = Set[]
      total_vs_codes[vs] = Set[]
      ValueSet.where(id: vs).first.concepts.each do |concept|
        total_vs_code_sys[vs].add(concept.code_system_oid)
        total_vs_codes[vs].add(concept.code)
      end
      percent_vs_codes[vs] = if vs_codes_found.key?(vs)
                               vs_codes_found[vs].count.to_f / total_vs_codes[vs].count
                             else
                               0
                             end
    end
  end

  def advanced_valueset_analysis(total_vs, value_sets_found, total_vs_code_sys, vs_code_sys_found, percent_vs_codes)
    analysis = {}
    analysis['uncovered_value_sets'] = (total_vs - value_sets_found).to_a # set difference
    analysis['value_set_coverage'] = (total_vs.count - analysis['uncovered_value_sets'].count).to_f / total_vs.count

    total_covered_vs_code_sys = 0
    analysis['uncovered_vs_code_sys'] = {}
    total_vs_code_sys.each do |k, v|
      analysis['uncovered_vs_code_sys'][k] = vs_code_sys_found.key?(k) ? (v - vs_code_sys_found[k]).to_a : v.to_a
      total_covered_vs_code_sys += (v.count - analysis['uncovered_vs_code_sys'][k].count)
    end

    total_vs_code_sys_count = total_vs_code_sys.values.sum(&:count)
    analysis['value_set_code_system_coverage'] = total_covered_vs_code_sys.to_f / total_vs_code_sys_count
    analysis['average_percent_vs_codes'] = percent_vs_codes.values.sum.to_f / percent_vs_codes.count
    analysis
  end

  def coverage_analysis(measures)
    analysis = {}
    clause_coverage_summary, population_coverage_summary = generate_coverage_summary(measures)
    analysis['coverage_per_measure'] = clause_coverage_summary
    coverage_min_info = clause_coverage_summary.min_by { |_k, v| v }
    analysis['minimum_coverage_measure'] = coverage_min_info[0]
    analysis['minimum_coverage_percentage'] = coverage_min_info[1]
    analysis['average_coverage'] = clause_coverage_summary.values.inject { |a, b| a + b } / clause_coverage_summary.length
    analysis['population_coverage'] = population_coverage_summary['total_population_coverage']
    analysis['unhit_populations_by_measure'] = population_coverage_summary['unhit_populations_by_measure']
    analysis
  end

  def generate_analysis(patients, measure, bundle)
    @patients = patients
    @measure = measure
    @bundle = bundle
    # TODO: double check stratifications in measure relevance hash

    # collate basic patient information
    measures_found, de_types_found, value_sets_found, vs_codes_found = collate_patient_data

    # basic analysis attributes
    relevant_measures = @measure ? [@measure] : @bundle.measures
    analysis = basic_analysis(relevant_measures, measures_found, de_types_found, value_sets_found)

    # find the number of code systems per valueset for all valuesets
    vs_code_sys_found = collate_vs_code_sys(value_sets_found)

    # find all valuesets in relevant measures
    total_vs = all_valuesets(relevant_measures)

    # find the number of code systems, codes, and percent code coverage per valueset for all valuesets
    total_vs_code_sys = {}
    total_vs_codes = {}
    percent_vs_codes = {}
    per_vs_stats(total_vs, total_vs_code_sys, total_vs_codes, vs_codes_found, percent_vs_codes)
    # create analysis hash
    analysis.merge!(advanced_valueset_analysis(total_vs, value_sets_found, total_vs_code_sys, vs_code_sys_found, percent_vs_codes))
    analysis.merge!(coverage_analysis(measures_found))
    analysis
  end
end
