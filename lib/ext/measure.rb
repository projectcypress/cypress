# yes this is a bit ugly as it is aliasing The measure class but it
# works for now until we can truley unify these items accross applications
Measure = HealthDataStandards::CQM::Measure

class Measure
  include HealthDataStandards::Export
  include HealthDataStandards::CQM
  field :bundle_id, type: BSON::ObjectId
  index bundle_id: 1
  index id: 1, sub_id: 1

  def display_name
    sub_id ? "#{cms_id} (#{sub_id}) #{name}" : "#{cms_id} #{name}"
  end

  def cms_int
    return 0 unless cms_id
    start_marker = 'CMS'
    end_marker = 'v'
    cms_id[/#{start_marker}(.*?)#{end_marker}/m, 1].to_i
  end

  def data_criteria
    self['hqmf_document']['data_criteria'].map { |key, val| { key => val } }
  end

  def smoking_gun_data(patient_cache_filter = {})
    ::Measure.calculate_smoking_gun_data(bundle_id, hqmf_id, patient_cache_filter)
  end

  # Calculate the smoking gun data for the given hqmf_id with the given patient_cache_filter
  # The  filter will allow us to segment the cache by things like test_id required for Cypress.
  def self.calculate_smoking_gun_data(bundle_id, hqmf_id, patient_cache_filter = {})
    values = {}
    measure = Measure.top_level.where(hqmf_id: hqmf_id, bundle_id: bundle_id).first
    hqmf_measure = measure.as_hqmf_model

    population_codes, sub_ids = return_population_codes(hqmf_measure)

    rationals = PatientCache.smoking_gun_rational(measure.hqmf_id, sub_ids, patient_cache_filter)
    rationals.each_pair do |mrn, rash|
      values[mrn] = []
      population_codes.each do |pop_code|
        population_criteria = hqmf_measure.population_criteria(pop_code)
        next unless population_criteria.preconditions
        parent = population_criteria.preconditions[0]
        values[mrn].concat loop_preconditions(hqmf_measure, parent, rash)
      end # population_codes
      values[mrn].uniq!
    end
    values
  end

  def self.return_population_codes(mes)
    population_codes = []
    sub_ids = []
    population_keys = ('a'..'zz').to_a

    # Do not bother with populaions that contain stratifications
    mes.populations.each_with_index do |population, index|
      next unless population['stratification'].nil?
      sub_ids << population_keys[index]
      HQMF::PopulationCriteria::ALL_POPULATION_CODES.each do |code|
        population_codes << population[code] if population[code]
      end
    end
    sub_ids = nil if sub_ids.length <= 1
    [population_codes.uniq, sub_ids]
  end

  def self.handle_non_derived_critiera(hqmf, data_criteria, rationale)
    result = []
    template = HQMF::DataCriteria.template_id_for_definition(data_criteria.definition,
                                                             data_criteria.status,
                                                             data_criteria.negation)
    value_set_oid = data_criteria.code_list_id
    begin
      qrda_template = QRDA::EntryTemplateResolver.qrda_oid_for_hqmf_oid(template, value_set_oid)
    rescue
      value_set_oid = 'In QRDA Header (Non Null Value)'
      qrda_template = 'N/A'
    end # end begin recue
    description = "#{HQMF::DataCriteria.title_for_template_id(template).titleize}: #{data_criteria.title}"
    result << { description: description, oid: value_set_oid, template: qrda_template, rationale: rationale[data_criteria.id] }
    if data_criteria.temporal_references
      data_criteria.temporal_references.each do |temporal_reference|
        next if temporal_reference.reference.id == 'MeasurePeriod'
        result.concat loop_data_criteria(hqmf, hqmf.data_criteria(temporal_reference.reference.id), rationale)
      end # end  data_criteria.temporal_references.each do |temporal_reference|
    end # end if data_criteria.temporal_references
    result
  end

  def self.loop_data_criteria(hqmf, data_criteria, rationale)
    result = []
    return result unless rationale[data_criteria.id]
    if data_criteria.type != :derived
      result = handle_non_derived_critiera(hqmf, data_criteria, rationale)
    else # data_criteria.type != :derived
      (data_criteria.children_criteria || []).each do |child_id|
        result.concat loop_data_criteria(hqmf, hqmf.data_criteria(child_id), rationale)
      end
    end
    result
  end

  def self.loop_preconditions(hqmf, parent, rationale)
    result = []
    parent.preconditions.each do |precondition|
      parent_key = "precondition_#{parent.id}"
      key = "precondition_#{precondition.id}"
      if precondition.preconditions.empty?
        data_criteria = hqmf.data_criteria(precondition.reference.id)
        result.concat loop_data_criteria(hqmf, data_criteria, rationale)
      elsif rationale[parent_key] && rationale[key]
        result.concat loop_preconditions(hqmf, precondition, rationale)
      end
    end
    result
  end
end
