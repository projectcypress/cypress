module Cypress
  module DataCriteriaSelector
    def data_criteria_selector(measure, prng)
      # Criterias to be used in C1 checklist
      criterias = []
      # Possible data criterias that don't have attributes
      data_criteria_without_att = {}
      # Criteria types in C1 checklist
      criteria_types = []
      # Clone and strip out data criteria with the negation field.  Negations are now tracked with attributes
      all_data_criteria = measure[:source_data_criteria].clone.keep_if { |_key, sdc| sdc['negation'] == false }
      dcs_with_attribute = measure[:source_data_criteria].clone
      dcs_with_attribute.keep_if { |_k, data_criteria| coded_attributes?(data_criteria) }
      # Loads list of value sets for the measure in question
      measure.oids.each do |oid|
        currnet_count = dcs_with_attribute.size
        match_attributes(dcs_with_attribute, oid, criterias, data_criteria_without_att, criteria_types)
        # If a DC with attribute is found, go to next
        next if dcs_with_attribute.size > currnet_count

        match_data_criteria(all_data_criteria, oid, data_criteria_without_att, criteria_types)
      end
      # number of data criteria with attributes or negations
      interesting_criteria = criterias.size
      # selects data criteria without attributes or negations (from criteria types not already used)
      data_criteria_without_att.values.sample(3, random: prng).each { |value| criterias << value }
      [criterias, interesting_criteria]
    end

    def coded_attributes?(data_criteria)
      if data_criteria['attributes']
        data_criteria['attributes'].keep_if { |av| av['attribute_valueset'] }.empty? ? false : true
      else
        false
      end
    end

    # Matches a data criteria coded field value with provided data_criteria_value
    def match_attributes(data_criterias, data_criteria_value, selected_dc, data_criteria_without_att, criteria_types)
      data_criterias.each do |dc_key, dc_value|
        next unless dc_value['attributes']
        next if dc_value['attributes'].map { |av| av['attribute_valueset'] == data_criteria_value ? true : nil }.compact.empty?
        next if criteria_types.include? dc_value.type

        selected_dc << dc_key
        criteria_types << dc_value.type
        data_criteria_without_att.delete(dc_value.type) if data_criteria_without_att.key?(dc_value.type)
      end
    end

    # Matches a data criteria code set or negation code set
    def match_data_criteria(data_criterias, data_criteria_value, data_criteria_without_att, criteria_types)
      data_criterias.each do |dc_key, dc_value|
        # If the criterias being tested do not already include the current data criteria type
        next unless criteria_types.exclude?(dc_value.type) && (dc_value['code_list_id'] == data_criteria_value)

        data_criteria_without_att[dc_value.type] = dc_key
      end
    end
  end
end
