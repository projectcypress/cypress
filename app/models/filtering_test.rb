class FilteringTest < ProductTest
  accepts_nested_attributes_for :tasks

  def create_subtasks
    criteria = %w('races', 'ethnicities', 'genders', 'payers').shuffle
    tasks << C4Task.new(options: { 'filters' => { criteria.shift => [], criteria.shift => [] } })
    tasks << C4Task.new(options: { 'filters' => { criteria.shift => [], criteria.shift => [] } })
    tasks << C4Task.new(options: { 'filters' => { 'providers' => [] } })
    tasks << C4Task.new(options: { 'filters' => { 'problems' => [] } })
    save!
  end
end
