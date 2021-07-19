# frozen_string_literal: true

module Cypress
  class ScoopAndFilter
    def initialize(measures, code_description_hash)
      @valuesets = measures.collect(&:value_sets).flatten.uniq
      @code_description_hash = code_description_hash
      @relevant_codes = codes_in_measures
      @de_category_statuses_for_measures = get_non_demographic_category_statuses(measures)
    end

    # return an array of all of the concepts in all of the valueset for the measure
    def codes_in_measures
      codes = @code_description_hash.keys
      code_list = @valuesets.collect { |vs| code_with_vs(vs) }.flatten
      code_list.map do |cl|
        { code: cl.code, system: cl.code_system_oid, vs: cl.vs_oid } if codes.include?("#{cl.code}:#{cl.code_system_oid}".tr('.', '_'))
      end.compact
    end

    def code_with_vs(valueset)
      valueset.concepts.collect { |con| { code: con.code, code_system_oid: con.code_system_oid, vs_oid: valueset.oid } }
    end

    def get_non_demographic_category_statuses(measures)
      measures.collect do |measure|
        measure.source_data_criteria.map { |cr| data_element_category_and_status(cr) unless cr.qdmCategory == 'patient_characteristic' }
      end.flatten.uniq
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
      data_element.dataElementCodes.keep_if { |de_code| @relevant_codes.any? { |rc| rc.code == de_code.code && rc.system == de_code.system } }
      # Do not try to replace with negated valueset if all codes are removed
      return if data_element.dataElementCodes.blank?

      add_description_to_data_element(data_element)
      return unless data_element.respond_to?('negationRationale') && data_element.negationRationale

      replace_negated_code_with_valueset(data_element, multi_vs_negation_elements)
      # add data element valueset and other potentially relevant valueset descriptions
      codes = (multi_vs_negation_elements + [data_element]).map { |de| "#{de.dataElementCodes.first.code}:#{de.dataElementCodes.first.system}" }
      Cypress::QRDAPostProcessor.build_code_descriptions(codes, patient, patient.bundle)
    end

    def data_element_category_and_status(data_element)
      { category: data_element.qdmCategory, status: data_element['qdmStatus'] }
    end

    # returns true if a patients data element is used by a measure
    def data_element_used_by_measure(data_element)
      @de_category_statuses_for_measures.include?(category: data_element['qdmCategory'], status: data_element['qdmStatus'])
    end

    def add_description_to_data_element(data_element)
      de = data_element
      dec = de.codes.first
      de.description = @code_description_hash["#{dec.code}:#{dec.system}".tr('.', '_')]
    end

    # For negated elements, replace codes (that aren't direct reference codes) with valuesets.
    # If a code is in multiple valuesets, create new entries to be added to record
    def replace_negated_code_with_valueset(data_element, multi_vs_negation_elements)
      de = data_element
      neg_vs = @relevant_codes.select { |rc| rc.code == de.codes.first.code && rc.system == de.codes.first.system }.map(&:vs)

      negated_valueset = neg_vs.first
      neg_vs.drop(1).each do |additional_vs|
        next if additional_vs[0, 3] == 'drc'

        de_for_additional_vs = data_element.clone
        de_for_additional_vs.id = BSON::ObjectId.new.to_s
        de_for_additional_vs.dataElementCodes = [{ code: additional_vs, system: '1.2.3.4.5.6.7.8.9.10' }]
        multi_vs_negation_elements << de_for_additional_vs
      end

      # If the first three characters of the valueset oid is drc, this is a direct reference code, not a valueset.  Do not negate a valueset here.
      return if negated_valueset[0, 3] == 'drc'

      data_element.dataElementCodes = [{ code: negated_valueset, system: '1.2.3.4.5.6.7.8.9.10' }]
    end
  end
end
