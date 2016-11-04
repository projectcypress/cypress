include Cypress::DataCriteriaSelector

class ChecklistTest < ProductTest
  embeds_many :checked_criteria, class_name: 'ChecklistSourceDataCriteria'
  accepts_nested_attributes_for :checked_criteria, allow_destroy: true

  def status
    return 'incomplete' if measures.empty?
    return 'incomplete' if num_measures_complete != measures.count
    return 'passing' unless product.c3_test
    return 'incomplete' unless tasks.c1_manual_task && tasks.c1_manual_task.most_recent_execution
    tasks.c1_manual_task.most_recent_execution.status_with_sibling == 'passing' ? 'passing' : 'incomplete'
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
      checked_criteria.each do |criteria|
        m_ids << criteria.measure_id unless m_ids.include? criteria.measure_id
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
	  #byebug
    prng = Random.new(self.rand_seed.to_i)

    # For each measure selected iterate on finding interesting data criteria
    measure_criteria_map, measure_ranks = criteria_map_and_measure_ranks(prng)

    # include all measures in checklist measures if c2 was not selected (and there are no measure tests)
    include_all_measures = product.product_tests.measure_tests.count == 0

    # shuffle the top 8 (4 + 4) measures if all measures are not being included
    measure_ranks, max_num_checklist_measures = shuffle_top_measures(measure_ranks, include_all_measures, prng)

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

  def criteria_map_and_measure_ranks(prng)
    measure_criteria_map = {}
    measure_rank_map = {}
    measures.each do |measure|
      measure_criteria_map[measure], measure_rank_map[measure] = data_criteria_selector(measure, prng)
    end
    measure_ranks = measure_rank_map.sort_by { |_key, value| value }
    [measure_criteria_map, measure_ranks]
  end

  # edits the order of the top 8 (4 + 4) measures
  def shuffle_top_measures(measure_ranks, include_all_measures = false, prng)
  #byebug
    max_num_checklist_measures = product.measure_ids.count
    unless include_all_measures
      max_num_checklist_measures = CAT1_CONFIG['number_of_checklist_measures']
      top = measure_ranks.pop(max_num_checklist_measures + 4).shuffle(random:prng)
      measure_ranks += top
    end
    [measure_ranks, max_num_checklist_measures]
  end

  def build_execution_errors_for_incomplete_checked_criteria(execution)
    checked_criteria.each do |crit|
      next if crit.passed_qrda
      msg = "#{crit.printable_name} not complete"
      # did not add ":validator_type =>", not sure if this will be an issue in execution show
      execution.execution_errors.build(:message => msg, :msg_type => :error, :validator => :qrda_cat1)
    end
  end

  def cms_id_from_measure_id(measure_id)
    Measure.find_by(_id: measure_id).cms_id
  rescue
    'cms id not found'
  end
end
