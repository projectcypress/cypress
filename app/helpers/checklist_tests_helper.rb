module ChecklistTestsHelper
  def disable_qrda_submission?
    # only disable if none of the measures have all good checklist criteria
    @product_test.checked_criteria.group_by(&:measure_id).values.all? { |cc_group| cc_group.any? { |cc| !cc.checklist_complete? } }
  end

  def checklist_test_criteria_attribute(measure, criteria)
    if criteria[:field_values]
      if criteria[:field_values].keys[0] == 'FLFS'
        fulfills_reference(measure, criteria[:field_values]['FLFS'].reference)
      else
        criteria[:field_values].keys[0].tr('_', ' ').capitalize
      end
    elsif criteria[:negation]
      'Negation Code'
    elsif criteria[:value] && criteria[:value][:system] != 'Administrative Sex'
      'Result'
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
    if criteria[:field_values]
      true if criteria[:field_values].values[0].type == 'CD'
    elsif criteria[:value]
      true if criteria[:value].type == 'CD' && criteria[:value][:system] != 'Administrative Sex'
    elsif criteria['negation_code_list_id']
      true
    end
  end

  def lookup_valueset_name(oid)
    vs = HealthDataStandards::SVS::ValueSet.where(oid: oid)
    return oid unless vs && vs.first
    "#{vs.first.display_name}"
  end


  def lookup_valueset_oid(oid)
    vs = HealthDataStandards::SVS::ValueSet.where(oid: oid)
    return oid unless vs && vs.first
    "#{oid}"
  end

  def lookup_codevalues(oid, bundle)
    vs = HealthDataStandards::SVS::ValueSet.where(oid: oid)
    return [] unless vs && vs.first
    vs.first.concepts.map {|con| "#{con.display_name}: #{con.code}"}
  end
end
