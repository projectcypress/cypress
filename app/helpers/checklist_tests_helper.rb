module ChecklistTestsHelper
  def checklist_test_criteria_attribute(measure, criteria)
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

  # argument fv stands for field_value (Hash)
  def length_of_stay_string(fv)
    msg = ''
    if fv['low']
      msg += "#{fv['low']['value']} #{fv['low']['unit']}"
      msg += less_than_symbol(fv['low']['inclusive?'])
    end
    msg += 'stay'
    if fv['high']
      msg += less_than_symbol(fv['high']['inclusive?'])
      msg += "#{fv['high']['value']} #{fv['high']['unit']}"
    end
    msg
  end

  def less_than_symbol(inclusive)
    inclusive ? ' &#8804; ' : ' < '
  end

  def coded_attribute?(criteria)
    true if criteria[:field_values] && criteria[:field_values].values[0].type == 'CD' || criteria['negation_code_list_id']
  end
end
