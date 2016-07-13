class ChecklistTest < ProductTest
  embeds_many :checked_criteria, class_name: 'ChecklistSourceDataCriteria'
  accepts_nested_attributes_for :checked_criteria, allow_destroy: true

  def status
    return 'incomplete' if measures.empty?
    num_measures_complete == measures.count ? 'passing' : 'incomplete'
  end

  def num_measures_complete
    return 0 if checked_criteria.count == 0
    num_complete = 0
    measures.each do |measure|
      criterias = checked_criteria.select { |criteria| criteria.measure_id == measure.id.to_s }
      num_complete += 1 if criterias.count(&:complete?) == criterias.count
    end
    num_complete
  end

  def num_measures_not_started
    num_not_started = 0
    measures.each do |measure|
      criterias = checked_criteria.select { |criteria| criteria.measure_id == measure.id.to_s }
      num_not_started += 1 unless criterias.count(&:complete?) > 0
    end
    num_not_started
  end

  def measures
    # measure list is changed once checklist is created, measures are based on checklist criteria
    if !checked_criteria.empty?
      m_ids = []
      checked_criteria.each do |critiera|
        m_ids << critiera.measure_id unless m_ids.include? critiera.measure_id
      end
      Measure.where(:_id.in => m_ids)
    else
      super
    end
  end

  def measure_status(measure_id)
    criterias = checked_criteria.select { |criteria| criteria.measure_id == measure_id.to_s }
    return 'not_started' if criterias.count { |criteria| criteria.complete?.nil? } == criterias.count
    pass_count = criterias.count(&:complete?)
    pass_count == criterias.count ? 'passed' : 'failed'
  end

  def create_checked_criteria
    checked_criterias = []
    checklist_measures = []

    # For each measure selected iterate on finding interesting data criteria
    measure_criteria_map, measure_ranks = criteria_map_and_measure_ranks

    # include all measures in checklist measures if c2 was not selected (and there are no measure tests)
    include_all_measures = product.product_tests.measure_tests.count == 0

    # shuffle the top 8 (4 + 4) measures if all measures are not being included
    measure_ranks, max_num_checklist_measures = shuffle_top_measures(measure_ranks, include_all_measures)

    # create checked criteria
    measure_ranks.reverse_each do |value|
      next if checklist_measures.include? value[0].hqmf_id                                      # skip submeasures
      next if !include_all_measures && checklist_measures.size > max_num_checklist_measures - 1 # skip if four checklist measures already exist
      checklist_measures << value[0].hqmf_id
      measure_criteria_map[value[0]].each do |criteria_key|
        checked_criterias.push(measure_id: value[0].id.to_s, source_data_criteria: criteria_key)
      end
    end
    # Measure ids updated to the ones selected for measure test
    self.measure_ids = checklist_measures
    self.checked_criteria = checked_criterias
    save!
  end

  def criteria_map_and_measure_ranks
    measure_criteria_map = {}
    measure_rank_map = {}
    measures.each do |measure|
      measure_criteria_map[measure], measure_rank_map[measure] = data_criteria_selector(measure)
    end
    measure_ranks = measure_rank_map.sort_by { |_key, value| value }
    [measure_criteria_map, measure_ranks]
  end

  # edits the order of the top 8 (4 + 4) measures
  def shuffle_top_measures(measure_ranks, include_all_measures = false)
    max_num_checklist_measures = product.measure_ids.count
    unless include_all_measures
      max_num_checklist_measures = CAT1_CONFIG['number_of_checklist_measures']
      top = measure_ranks.pop(max_num_checklist_measures + 4).shuffle
      measure_ranks += top
    end
    [measure_ranks, max_num_checklist_measures]
  end

  def build_execution_errors_for_incomplete_checked_criteria(execution)
    checked_criteria.each do |crit|
      next if crit.complete?
      msg = "#{cms_id_from_measure_id(crit.measure_id)}: data criteria\"#{crit.source_data_criteria}\" not complete"
      # did not add ":validator_type =>", not sure if this will be an issue in execution show
      execution.execution_errors.build(:message => msg, :msg_type => :error, :validator => :qrda_cat1)
    end
  end

  def cms_id_from_measure_id(measure_id)
    Measure.find_by(_id: measure_id).cms_id
  rescue
    'cms id not found'
  end

  def data_criteria_selector(measure)
    # Criterias to be used in C1 checklist
    criterias = []
    # Possible data criterias that don't have attributes or negations
    data_criteria_without_att = {}
    # Criteria types in C1 checklist
    criteria_types = []
    all_data_criteria = measure.all_data_criteria.shuffle
    dcs_with_attribute = all_data_criteria.clone.keep_if(&:field_values)
    # Loads prioritized list of value sets for the measure in question
    CAT1_CONFIG[measure.hqmf_id].each do |data_criteria_filter|
      if data_criteria_filter['IsAttribute']
        match_field_values(dcs_with_attribute, data_criteria_filter['ValueSet'], criterias, data_criteria_without_att, criteria_types)
      else
        match_data_criteria(all_data_criteria, data_criteria_filter['ValueSet'], criterias, data_criteria_without_att, criteria_types)
      end
    end
    # number of data criteria with attributes or negations
    interesting_criteria = criterias.size
    # selects data criteria without attributes or negations (from criteria types not already used)
    data_criteria_without_att.values.sample(3).each { |value| criterias << value }
    [criterias, interesting_criteria]
  end

  # Matches a data criteria coded field value with provided data_criteria_value
  def match_field_values(data_criterias, data_criteria_value, selected_dc, data_criteria_without_att, criteria_types)
    data_criterias.each do |dc|
      key = dc.field_values.keys[0]
      next unless dc.field_values[key].type == 'CD' && dc.field_values[key].code_list_id == data_criteria_value && criteria_types.exclude?(dc.type)
      selected_dc << dc.id
      criteria_types << dc.type
      data_criteria_without_att.delete(dc.type) if data_criteria_without_att.key?(dc.type)
    end
  end

  # Matches a data criteria code set or negation code set
  def match_data_criteria(data_criterias, data_criteria_value, selected_dc, data_criteria_without_att, criteria_types)
    data_criterias.each do |dc|
      # If the criterias being tested do not already include the current data criteria type
      next unless criteria_types.exclude?(dc.type) && (dc.code_list_id == data_criteria_value || dc.negation_code_list_id == data_criteria_value)
      # If the criteria has a negation or field_value, it is selected
      # If not, it is put in a hash for possible inclusion in data criteria
      if dc.negation_code_list_id == data_criteria_value || dc.field_values
        selected_dc << dc.id
        criteria_types << dc.type
      else
        data_criteria_without_att[dc.type] = dc.id
      end
    end
  end
end
