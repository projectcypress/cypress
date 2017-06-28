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

  def available_data_criteria(measure, criteria, original_sdc)
    dc_hash = {}
    og_string = ''
    measure.data_criteria.each do |dc|
      next if substituable_data_criteria?(dc)
      dc_string = dc[dc.keys[0]].negation ? "#{dc[dc.keys[0]].description} - negation" : dc[dc.keys[0]].description
      dc_hash[dc_string] = dc.keys[0]
      # Store the original data source criteria and display string, makes sure you can reselect the orignal criteria
      # This is important for when the same criteria is used in multiple ways in the same measure
      if dc[dc.keys[0]].source_data_criteria == criteria.source_data_criteria
        og_string = dc_string
      end
    end
    dc_hash[og_string] = original_sdc
    Hash[dc_hash.sort]
  end

  # A data criteria can be uesd for subtitution if it isn't derived (e.g., Occurrence A of, or birthtime)
  def substituable_data_criteria?(criteria)
    if criteria[criteria.keys[0]].definition == 'derived' || criteria[criteria.keys[0]].type == 'derived' ||
       (criteria[criteria.keys[0]].type == 'characteristic' && criteria[criteria.keys[0]].property == 'birthtime')
      return true
    else
      return false
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
    vs.first.display_name
  end

  def lookup_valueset_long_name(oid)
    vs = HealthDataStandards::SVS::ValueSet.where(oid: oid)
    return oid unless vs && vs.first
    "#{vs.first.display_name}: #{oid}"
  end

  def lookup_codevalues(oid, bundle)
    vs = HealthDataStandards::SVS::ValueSet.where(oid: oid, bundle_id: bundle)
    return [] unless vs && vs.first
    vs.first.concepts.map { |con| "#{con.display_name}: #{con.code}" }
  end
end
