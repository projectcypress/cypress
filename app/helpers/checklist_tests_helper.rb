module ChecklistTestsHelper
  def checklist_test_criteria_attribute(criteria)
    if criteria[:field_values]
      if criteria[:field_values].keys[0] == 'FLFS'
        fulfills_reference(measure, criteria[:field_values]['FLFS'].reference)
      else
        criteria[:field_values].keys[0].tr('_', ' ').capitalize
      end
    elsif criteria[:negation]
      'Negation Code'
    else
      ''
    end
  end

  def fulfills_reference(measure, referenced_criteria)
    data_criterias = measure.data_criteria
    data_criterias.each do |data_criteria|
      return 'Fulfills - ' + data_criteria[referenced_criteria].description if data_criteria[referenced_criteria]
    end
  end
end
