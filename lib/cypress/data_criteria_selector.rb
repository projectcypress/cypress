# frozen_string_literal: true

module Cypress
  module DataCriteriaSelector
    def data_criteria_selector(measure, prng)
      # Criterias to be used in C1 checklist
      criterias = []
      # Possible data criterias that don't have attributes
      data_criteria_without_att = {}
      # Criteria types in C1 checklist
      criteria_types = []
      all_data_criteria = measure.source_data_criteria.clone
      dcs_with_attribute = measure.source_data_criteria.clone
      dcs_with_attribute.keep_if { |data_criteria| coded_attributes?(data_criteria) }
      # Loads list of value sets for the measure in question
      measure.value_sets.map(&:oid).each do |oid|
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
      if data_criteria.dataElementAttributes
        data_criteria.dataElementAttributes.any?(&:attribute_valueset)
      else
        false
      end
    end

    # Matches a data criteria coded field value with provided data_criteria_value
    def match_attributes(data_criterias, data_criteria_value, selected_dc, data_criteria_without_att, criteria_types)
      data_criterias.each do |dc_value|
        valueset_or_drc = data_criteria_value
        # if a data_criteria_value is a Direct Reference Code, the "attribute_valueset" is actually the direct reference code itself.
        valueset_or_drc = ValueSet.find_by(oid: valueset_or_drc).concepts.first.code if valueset_or_drc[0, 4] == 'drc-'
        next unless dc_value.dataElementAttributes
        next if dc_value.dataElementAttributes.map { |av| av.attribute_valueset == valueset_or_drc ? true : nil }.compact.empty?
        next if criteria_types.include? dc_value._type

        selected_dc << dc_value
        criteria_types << dc_value._type
        data_criteria_without_att.delete(dc_value._type) if data_criteria_without_att.key?(dc_value._type)
      end
    end

    # Matches a data criteria code set or negation code set
    def match_data_criteria(data_criterias, data_criteria_value, data_criteria_without_att, criteria_types)
      data_criterias.each do |dc_value|
        # If the criterias being tested do not already include the current data criteria type
        next unless criteria_types.exclude?(dc_value._type) && (dc_value.codeListId == data_criteria_value)

        data_criteria_without_att[dc_value._type] = dc_value
      end
    end
  end
end
