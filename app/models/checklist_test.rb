# frozen_string_literal: true

class ChecklistTest < ProductTest
  include Cypress::DataCriteriaSelector

  embeds_many :checked_criteria, class_name: 'ChecklistSourceDataCriteria'
  accepts_nested_attributes_for :checked_criteria, allow_destroy: true

  after_create do |checklist_test|
    ChecklistTestSetupJob.perform_later(checklist_test)
  end

  def status
    return 'incomplete' if measures.empty?
    return 'passing' if num_measures_complete == measures.count && !product.c3_test
    return tasks.c1_checklist_task.most_recent_execution.status_with_sibling if tasks&.c1_checklist_task&.most_recent_execution

    'incomplete'
  end

  def num_measures_complete
    return 0 if checked_criteria.count.zero?

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
      num_not_started += 1 unless criterias.count(&:complete?).positive?
    end
    num_not_started
  end

  def measures
    # measure list is changed once checklist is created, measures are based on checklist criteria
    if checked_criteria.empty?
      bundle.measures.in(hqmf_id: measure_ids.sample(50))
    else
      m_ids = []
      checked_criteria.each do |criteria|
        m_ids << criteria.measure_id unless m_ids.include? criteria.measure_id
      end
      Measure.where(:_id.in => m_ids)
    end
  end

  def measure_status(measure_id)
    criterias = checked_criteria.select { |criteria| criteria.measure_id == measure_id.to_s }
    return 'not_started' if criterias.count == criterias.count { |criteria| criteria.complete?.nil? }
    # incomplete if no files have been uploaded
    return 'incomplete' if tasks.c1_checklist_task.most_recent_execution.nil?

    pass_count = criterias.count(&:complete?)
    pass_count == criterias.count ? 'passed' : 'failed'
  end

  def negate_valueset?(criteria, att_index)
    return false unless att_index

    criteria['dataElementAttributes'][att_index]['attribute_name'] == 'negationRationale'
  end

  # index of randomly sampled attribute that can be used in test
  def attribute_index(criteria)
    attributes = criteria['dataElementAttributes']
    return nil if attributes.blank?

    code_indices = []
    codeless_indices = []
    attributes.each_with_index do |attribute, index|
      next unless ApplicationController.helpers.available_attribute?(measure_ids, criteria, attribute)

      if attribute['attribute_valueset'].nil?
        next if attribute.attribute_name == 'id'

        # A codeless attribute (i.e. time periods, result, etc.)
        codeless_indices << index
      else
        # A coded attribute needs to have the valueset specified
        code_indices << index
      end
    end
    return code_indices.sample unless code_indices.empty?

    codeless_indices.sample unless codeless_indices.empty?
  end

  def create_checked_criteria
    checked_criterias = []
    checklist_measures = []
    prng = Random.new(rand_seed.to_i)

    # For each measure selected iterate on finding interesting data criteria
    measure_criteria_map, measure_ranks = criteria_map_and_measure_ranks(prng)

    # shuffle the top 8 (4 + 4) measures if all measures are not being included
    measure_ranks, max_num_checklist_measures = shuffle_top_measures(measure_ranks, prng)

    # create checked criteria
    measure_ranks.reverse_each do |measure, _rank|
      measure.reload
      # skip submeasures or if four checklist measures already exist
      next if (checklist_measures.include? measure.hqmf_id) || (checklist_measures.size > max_num_checklist_measures - 1)

      checklist_measures << measure.hqmf_id
      measure_criteria_map[measure].each do |criteria|
        att_index = attribute_index(criteria)
        # slice source_data_criteria to remove fields unrelated to the checklist test
        sdc = criteria.attributes.slice('qdmCategory', 'qdmStatus', '_type', 'hqmfOid', 'codeListId', 'description', 'dataElementAttributes', '_id')
        checked_criterias.push(ChecklistSourceDataCriteria.new(measure_id: measure.id.to_s, source_data_criteria: sdc,
                                                               attribute_index: att_index, negated_valueset: negate_valueset?(criteria, att_index)))
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
  def shuffle_top_measures(measure_ranks, prng)
    max_num_checklist_measures = CAT1_CONFIG['number_of_checklist_measures']
    top = measure_ranks.pop(max_num_checklist_measures + 4).shuffle(random: prng)
    measure_ranks += top
    [measure_ranks, max_num_checklist_measures]
  end

  def build_execution_errors_for_incomplete_checked_criteria(execution)
    checked_criteria.each do |crit|
      next if crit.passed_qrda

      msg = "#{crit.printable_name} not complete"
      # did not add ":validator_type =>", not sure if this will be an issue in execution show
      execution.execution_errors.build(message: msg, msg_type: :error, validator: :qrda_cat1)
    end
  end

  def archive_patients
    if patient_archive.path.nil?
      self.patient_archive = Cypress::CreateDownloadZip.create_c1_patient_zip(self)
      save
    end
    patient_archive
  end
end
