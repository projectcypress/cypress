module ChecklistTestsHelper
  def disable_qrda_submission?
    # only disable if none of the measures have all good checklist criteria
    @product_test.checked_criteria.group_by(&:measure_id).values.all? { |cc_group| cc_group.any? { |cc| !cc.checklist_complete? } }
  end

  def checklist_test_criteria_attribute(criteria, attribute_index)
    if criteria[:attributes]
      criteria[:attributes][attribute_index][:attribute_name]
    elsif criteria[:value] && criteria[:value][:system] != 'Administrative Sex'
      'Result'
    else
      ''
    end
  end

  def available_data_criteria(measure, criteria, original_sdc)
    dc_hash = {}
    og_string = ''
    measure.source_data_criteria.each do |dc_key, dc|
      next if unsubstituable_data_criteria?(dc)
      dc_hash[dc.description] = dc_key
      # Store the original data source criteria and display string, makes sure you can reselect the orignal criteria
      # This is important for when the same criteria is used in multiple ways in the same measure
      og_string = dc.description if dc.source_data_criteria == criteria.source_data_criteria
    end
    dc_hash[og_string] = original_sdc
    Hash[dc_hash.sort]
  end

  # A data criteria cannot be used for subtitution if it is derived (e.g., Occurrence A of), or birthtime
  def unsubstituable_data_criteria?(cr)
    cr['negation'] || cr['definition'] == 'derived' || cr['type'] == 'derived' || (cr['type'] == 'characteristic' && cr['property'] == 'birthtime')
  end

  def coded_attribute?(criteria, attribute_index)
    if criteria[:attributes]
      true if criteria[:attributes][attribute_index][:attribute_valueset]
    elsif criteria[:value]
      true if criteria[:value].type == 'CD' && criteria[:value][:system] != 'Administrative Sex'
    end
  end

  def lookup_valueset_name(oid)
    vs = ValueSet.where(oid: oid)
    return oid unless vs&.first
    vs.first.display_name
  end

  def lookup_valueset_long_name(oid)
    vs = ValueSet.where(oid: oid)
    return oid unless vs&.first
    "#{vs.first.display_name}: #{oid}"
  end

  def lookup_codevalues(oid, bundle)
    vs = ValueSet.where(oid: oid, bundle_id: bundle)
    return [] unless vs&.first
    # vs.first.concepts.map { |con| con.display_name + ":" + con.code }
    vs.first.concepts.map { |con| [con.display_name, con.code] }
  end

  def direct_reference_code?(valueset)
    valueset[0, 3] == 'drc'
  end
end
