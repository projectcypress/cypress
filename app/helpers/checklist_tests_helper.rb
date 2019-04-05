module ChecklistTestsHelper
  def disable_qrda_submission?
    # only disable if none of the measures have all good checklist criteria
    @product_test.checked_criteria.group_by(&:measure_id).values.all? { |cc_group| cc_group.any? { |cc| !cc.checklist_complete? } }
  end

  def checklist_test_criteria_attribute(criteria, attribute_index)
    if criteria['dataElementAttributes']
      criteria['dataElementAttributes'][attribute_index]['attribute_name']
    else
      ''
    end
  end

  def hash_for_data_criteria(data_criteria)
    Digest::SHA2.hexdigest("#{data_criteria['_type']} #{data_criteria['codeListId']}")
  end

  def available_data_criteria(measure, criteria, original_sdc)
    dc_hash = {}
    og_string = ''
    measure.source_data_criteria.each do |dc|
      next if unsubstituable_data_criteria?(dc)

      dc_hash[dc['description']] = hash_for_data_criteria(dc)
      # Store the original data source criteria and display string, makes sure you can reselect the orignal criteria
      # This is important for when the same criteria is used in multiple ways in the same measure
      og_string = dc['description'] if dc == criteria
    end
    dc_hash[og_string] = hash_for_data_criteria(original_sdc)
    Hash[dc_hash.sort]
  end

  # A data criteria cannot be used for subtitution if it is derived (e.g., Occurrence A of), or birthtime
  def unsubstituable_data_criteria?(cr)
    cr['negation'] || cr['definition'] == 'derived' || cr['type'] == 'derived' || (cr['type'] == 'characteristic' && cr['property'] == 'birthtime')
  end

  def coded_attribute?(criteria, attribute_index)
    if criteria['dataElementAttributes']
      true if criteria['dataElementAttributes'][attribute_index]['attribute_valueset']
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

    [vs.first.display_name, oid]
  end

  def lookup_codevalues(oid, bundle = nil)
    filter = { oid: oid }
    filter.store(:bundle_id, bundle) unless bundle.nil?
    vs = ValueSet.where(filter)

    return [] unless vs&.first

    vs.first.concepts.map { |con| [con.display_name, con.code] }
  end

  def direct_reference_code?(valueset)
    valueset[0, 3] == 'drc'
  end
end
