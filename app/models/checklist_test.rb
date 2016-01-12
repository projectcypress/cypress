class ChecklistTest < ProductTest
  embeds_many :checked_criteria, class_name: 'ChecklistSourceDataCriteria'
  accepts_nested_attributes_for :checked_criteria, allow_destroy: true

  def num_measures_complete
    num_complete = 0
    Measure.top_level.where(:hqmf_id.in => measure_ids).each do |measure|
      criterias = checked_criteria.select { |criteria| criteria.measure_id == measure.id.to_s }
      num_complete += 1 if criterias.count(&:completed) == criterias.count
    end
    num_complete
  end

  def num_measures
    measure_ids.count
  end
end
