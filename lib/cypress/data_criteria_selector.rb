module Cypress
  module DataCriteriaSelector
    def data_criteria_selector(measure, prng)
      # Criterias to be used in C1 checklist
      criterias = []
      # Possible data criterias that don't have attributes or negations
      data_criteria_without_att = {}
      # Criteria types in C1 checklist
      criteria_types = []
      all_data_criteria = measure.all_data_criteria.shuffle(random: prng)
      dcs_with_attribute = all_data_criteria.clone.keep_if(&:field_values)
      # Loads list of value sets for the measure in question
      measure.oids.each do |oid|
        currnet_count = dcs_with_attribute.size
        match_field_values(dcs_with_attribute, oid, criterias, data_criteria_without_att, criteria_types)
        # If a DC with attribute is found, go to next
        next if dcs_with_attribute.size > currnet_count
        match_data_criteria(all_data_criteria, oid, criterias, data_criteria_without_att, criteria_types)
      end
      # number of data criteria with attributes or negations
      interesting_criteria = criterias.size
      # selects data criteria without attributes or negations (from criteria types not already used)
      data_criteria_without_att.values.sample(3, random: prng).each { |value| criterias << value }
      [criterias, interesting_criteria]
    end

    # Matches a data criteria coded field value with provided data_criteria_value
    def match_field_values(data_criterias, data_criteria_value, selected_dc, data_criteria_without_att, criteria_types)
      data_criterias.each do |dc|
        key = dc.field_values.keys[0]
        next unless dc.field_values[key].type == 'CD' && dc.field_values[key].code_list_id == data_criteria_value && criteria_types.exclude?(dc.type)
        selected_dc << dc.id
        criteria_types << dc.type
        data_criteria_without_att.delete(dc.type) if data_criteria_without_att.key?(dc.type)
      end
    end

    # Matches a data criteria code set or negation code set
    def match_data_criteria(data_criterias, data_criteria_value, selected_dc, data_criteria_without_att, criteria_types)
      data_criterias.each do |dc|
        # If the criterias being tested do not already include the current data criteria type
        next unless criteria_types.exclude?(dc.type) && (dc.code_list_id == data_criteria_value || dc.negation_code_list_id == data_criteria_value)
        # If the criteria has a negation or field_value, it is selected
        # If not, it is put in a hash for possible inclusion in data criteria
        if dc.negation_code_list_id == data_criteria_value || dc.field_values
          selected_dc << dc.id
          criteria_types << dc.type
        else
          data_criteria_without_att[dc.type] = dc.id
        end
      end
    end
  end
end
