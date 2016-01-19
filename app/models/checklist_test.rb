class ChecklistTest < ProductTest
  embeds_many :checked_criteria, class_name: 'ChecklistSourceDataCriteria'
  accepts_nested_attributes_for :checked_criteria, allow_destroy: true

  def measure_complete?(measure_id)
    criterias = checked_criteria.select { |criteria| criteria.measure_id == measure_id.to_s }
    criterias.count(&:completed) == criterias.count
  end
end
