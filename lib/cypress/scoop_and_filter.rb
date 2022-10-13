# frozen_string_literal: true

module Cypress
  class ScoopAndFilter
    def initialize(measures)
      @valuesets = measures.collect(&:value_sets).flatten.uniq
      @relevant_codes = codes_in_measures
      @de_category_statuses_for_measures = get_non_demographic_category_statuses(measures)
    end

    # return an array of all of the concepts in all of the valueset for the measure
    def codes_in_measures
      code_list = @valuesets.collect(&:concepts).flatten
      code_list.map { |cl| { code: cl.code, system: cl.code_system_oid } }
    end

    def get_non_demographic_category_statuses(measures)
      measures.collect do |measure|
        measure.source_data_criteria.map { |cr| data_element_category_and_status(cr) unless cr.qdmCategory == 'patient_characteristic' }
      end.flatten.uniq.compact
    end

    def scoop_and_filter(patient)
      demographic_criteria = patient.qdmPatient.dataElements.collect { |de| de if de.qdmCategory == 'patient_characteristic' }.compact
      # If a negated code belongs to multiple valuesets, we need to add a cloned entry for each valueset.
      # This array stores the cloned entries to be added
      multi_vs_negation_elements = []
      patient.qdmPatient.dataElements.keep_if { |de| data_element_used_by_measure(de) }
      patient.qdmPatient.dataElements.each do |data_element|
        scoop_and_filter_data_element_codes(data_element, multi_vs_negation_elements, patient)
        data_element.dataElementCodes.first
      end
      # keep data element if codes is not empty
      patient.qdmPatient.dataElements.keep_if { |data_element| data_element.dataElementCodes.present? }
      patient.qdmPatient.dataElements.concat(demographic_criteria)
      patient.qdmPatient.dataElements.concat(multi_vs_negation_elements)
      patient
    end

    private

    # Method to remove codes from a data element that are not relevant to measure.
    # Multi_vs_negation_elements is an array of cloned elements to add to patient record to capture all of the negated valuesets
    def scoop_and_filter_data_element_codes(data_element, multi_vs_negation_elements, patient)
      # keep if data_element code and codesystem is in one of the relevant_codes
      # Also keep all negated valuesets, we'll deal with those later
      data_element.dataElementCodes.keep_if do |de_code|
        (@relevant_codes.include?(code: de_code.code, system: de_code.system) || de_code.system == '1.2.3.4.5.6.7.8.9.10')
      end
      # Return if all codes have been removed
      return if data_element.dataElementCodes.blank?

      remove_irrelevant_valuesets_and_add_description_to_data_element(data_element)
      # Return if all codes and valuesets have been removed
      return if data_element.dataElementCodes.blank?
      return unless data_element.respond_to?('negationRationale') && data_element.negationRationale

      replace_negated_code_with_valueset(data_element, multi_vs_negation_elements)
      # add data element valueset and other potentially relevant valueset descriptions
      codes = (multi_vs_negation_elements + [data_element]).map { |de| "#{de.dataElementCodes.first.code}:#{de.dataElementCodes.first.system}" }
      Cypress::QRDAPostProcessor.build_code_descriptions(codes, patient, patient.bundle)
    end

    def data_element_category_and_status(data_element)
      { category: data_element.qdmCategory, status: data_element['qdmStatus'], oid: data_element['codeListId'] }
    end

    # returns true if a patients data element is used by a measure
    def data_element_used_by_measure(data_element)
      !@de_category_statuses_for_measures.index do |dcs|
        dcs[:category] == data_element['qdmCategory'] && dcs[:status] == data_element['qdmStatus']
      end.nil?
    end

    def remove_irrelevant_valuesets_and_add_description_to_data_element(data_element)
      de = data_element
      vsets = if de.codes.any? { |code| code.system == '1.2.3.4.5.6.7.8.9.10' }
                @valuesets.select { |vs| vs.oid == de.codes.select { |code| code.system == '1.2.3.4.5.6.7.8.9.10' }.first.code }
              else
                @valuesets.select { |vs| vs.concepts.any? { |c| c.code == de.codes.first.code && c.code_system_oid == de.codes.first.system } }
              end
      # A data element may have codes from multiple valusets, pick the first valueset for the description
      if vsets.blank?
        de.dataElementCodes.clear
        return
      end

      vs = vsets.first
      de.description = vs.display_name
    end

    def value_set_appropriate_for_data_element(data_element, valueset_oid)
      @de_category_statuses_for_measures.include?(category: data_element['qdmCategory'], status: data_element['qdmStatus'], oid: valueset_oid)
    end

    # For negated elements, replace codes (that aren't direct reference codes) with valuesets.
    # If a code is in multiple valuesets, create new entries to be added to record
    # rubocop:disable Metrics/AbcSize
    def replace_negated_code_with_valueset(data_element, multi_vs_negation_elements)
      de = data_element
      # If the data element already knows the negated valueset, use it
      if de.codes.any? { |code| code.system == '1.2.3.4.5.6.7.8.9.10' }
        # Remove the 'assumed' code for the valueset.  This assumed code is only used for calculation, not display.
        de.dataElementCodes.keep_if { |code| code.system == '1.2.3.4.5.6.7.8.9.10' }
        return
      end
      neg_vs = @valuesets.select { |vs| vs.concepts.any? { |c| c.code == de.codes.first.code && c.code_system_oid == de.codes.first.system } }
      neg_vs.keep_if { |nvs| value_set_appropriate_for_data_element(de, nvs.oid) }
      return if neg_vs.blank?

      negated_valueset = neg_vs.first
      neg_vs.drop(1).each do |additional_vs|
        next if additional_vs.oid[0, 3] == 'drc'

        de_for_additional_vs = data_element.clone
        # Create Ids from the source data element and the oid so they remain consistent
        de_for_additional_vs.id = BSON::ObjectId.from_data("#{data_element.id}#{additional_vs.oid}").to_s
        de_for_additional_vs.dataElementCodes = [{ code: additional_vs.oid, system: '1.2.3.4.5.6.7.8.9.10' }]
        multi_vs_negation_elements << de_for_additional_vs
      end

      # If the first three characters of the valueset oid is drc, this is a direct reference code, not a valueset.  Do not negate a valueset here.
      return if negated_valueset.oid[0, 3] == 'drc'

      data_element.dataElementCodes = [{ code: negated_valueset.oid, system: '1.2.3.4.5.6.7.8.9.10' }]
    end
    # rubocop:enable Metrics/AbcSize
  end
end
