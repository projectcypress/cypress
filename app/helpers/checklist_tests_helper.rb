module ChecklistTestsHelper
  def fulfills_reference(measure, referenced_criteria)
    data_criterias = measure.data_criteria
    data_criterias.each do |data_criteria|
      return 'Fulfills - ' + data_criteria[referenced_criteria].description if data_criteria[referenced_criteria]
    end
  end
end
