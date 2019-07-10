module PatientAnalysisHelper
  def collate_element_data(de, de_types_found, value_sets_found, vs_codes_found)
    de_types_found.add(de._type)
    de.dataElementCodes.each do |dec|
      # find all valuesets that contain data element code
      vs = ValueSet.where('concepts.code' => dec.code).map(&:oid)
      value_sets_found.merge(vs)
      vs.each do |oid|
        vs_codes_found[oid] = Set[] unless vs_codes_found.key?(oid)
        vs_codes_found[oid].add(dec.code)
      end
    end
  end

  def collate_patient_data
    measures_found = Set[]
    measure_pops_found = Set[]
    de_types_found = Set[]
    value_sets_found = Set[]
    vs_codes_found = {}

    @patients.each do |p|
      measures_found.merge(p.measure_relevance_hash.keys)
      p.measure_relevance_hash.each do |meas, v|
        v.each_key { |pop| measure_pops_found.add(meas + '|' + pop) }
      end
      p.qdmPatient.dataElements.each do |de|
        collate_element_data(de, de_types_found, value_sets_found, vs_codes_found)
      end
    end
    [measures_found, measure_pops_found, de_types_found, value_sets_found, vs_codes_found]
  end

  def generate_coverage_summary
    clause_results_by_measure = {}

    @patients.each do |p|
      p.calculation_results.each do |calculation_results|
        cms_id = calculation_results.measure.cms_id
        clause_results_by_measure[cms_id] ||= {}
        clause_results = calculation_results.clause_results
        clause_results.each do |result|
          key = result.library_name + '_' + result.localId
          clause_results_by_measure[cms_id][key] ||= false
          clause_results_by_measure[cms_id][key] = clause_results_by_measure[cms_id][key] || (result.final == 'TRUE')
        end
      end
    end

    clause_coverage_summaries = {}
    clause_results_by_measure.each do |cms_id, clause_results|
      covered_clauses = 0
      total_clauses = 0
      clause_results.each do |_key, covered|
        covered_clauses += 1 if covered
        total_clauses += 1
      end
      clause_coverage_summaries[cms_id] = (covered_clauses.fdiv(total_clauses) * 100).round(2)
    end

    clause_coverage_summaries
  end

  def collate_vs_code_sys(value_sets_found)
    vs_code_sys_found = {}
    value_sets_found.each do |vs|
      vs_code_sys_found[vs] = Set[]
      ValueSet.where(oid: vs).first.concepts.each do |concept|
        vs_code_sys_found[vs].add(concept.code_system_oid)
      end
    end
    vs_code_sys_found
  end

  def basic_analysis(relevant_measures, measures_found, measure_pops_found, de_types_found, value_sets_found)
    analysis = {}
    total_pops = relevant_measures.sum { |m| m.population_criteria.keys.count }
    analysis['patient_count'] = @patients.count
    analysis['measure_coverage'] = measures_found.count.to_f / relevant_measures.count
    analysis['population_coverage'] = measure_pops_found.count.to_f / total_pops
    analysis['data_element_types'] = de_types_found.count
    analysis['value_sets'] = value_sets_found.count
    analysis
  end

  def all_valuesets(relevant_measures)
    total_vs = Set[]
    relevant_measures.each do |m|
      measure_valuesets = ValueSet.find(m.value_set_ids)
      total_vs.merge(measure_valuesets.map(&:oid))
    end
    total_vs
  end

  def per_vs_stats(total_vs, total_vs_code_sys, total_vs_codes, vs_codes_found, percent_vs_codes)
    total_vs.each do |vs|
      total_vs_code_sys[vs] = Set[]
      total_vs_codes[vs] = Set[]
      ValueSet.where(oid: vs).first.concepts.each do |concept|
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

  def advanced_analysis(total_vs, value_sets_found, total_vs_code_sys, vs_code_sys_found, percent_vs_codes)
    analysis = {}
    analysis['uncovered_value_sets'] = total_vs - value_sets_found # set difference
    total_covered_vs = total_vs.count - analysis['uncovered_value_sets'].count
    analysis['value_set_coverage'] = total_covered_vs.to_f / total_vs.count

    total_covered_vs_code_sys = 0
    analysis['uncovered_vs_code_sys'] = {}
    total_vs_code_sys.each do |k, v|
      analysis['uncovered_vs_code_sys'][k] = vs_code_sys_found.key?(k) ? v - vs_code_sys_found[k] : v
      total_covered_vs_code_sys += (v.count - analysis['uncovered_vs_code_sys'][k].count)
    end

    total_vs_code_sys_count = total_vs_code_sys.values.sum(&:count)
    analysis['value_set_code_system_coverage'] = total_covered_vs_code_sys.to_f / total_vs_code_sys_count
    analysis['average_percent_vs_codes'] = percent_vs_codes.values.sum.to_f / percent_vs_codes.count
    coverage_summary = generate_coverage_summary
    analysis['coverage_per_measure'] = coverage_summary
    coverage_min_info = coverage_summary.min_by { |_k, v| v }
    analysis['minimum_coverage_measure'] = coverage_min_info[0]
    analysis['minimum_coverage_percentage'] = coverage_min_info[1]
    analysis['average_coverage'] = coverage_summary.values.inject { |a, b| a + b } / coverage_summary.length
    analysis
  end

  def generate_analysis(patients, measure, bundle)
    @patients = patients
    @measure = measure
    @bundle = bundle
    # TODO: double check stratifications in measure relevance hash

    # collate basic patient information
    measures_found, measure_pops_found, de_types_found, value_sets_found, vs_codes_found = collate_patient_data

    # basic analysis attributes
    relevant_measures = @measure ? [@measure] : @bundle.measures
    analysis = basic_analysis(relevant_measures, measures_found, measure_pops_found, de_types_found, value_sets_found)

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
    analysis.merge(advanced_analysis(total_vs, value_sets_found, total_vs_code_sys, vs_code_sys_found, percent_vs_codes))
  end
end
