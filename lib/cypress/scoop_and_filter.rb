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
      code_list.map { |cl| { code: cl.code, codeSystemOid: cl.code_system_oid } }
    end

    def get_non_demographic_category_statuses(measures)
      measures.collect do |measure|
        measure.source_data_criteria.map { |cr| data_element_category_and_status(cr) unless cr.qdmCategory == 'patient_characteristic' }
      end.flatten.uniq
    end

    def scoop_and_filter(patient)
      demographic_criteria = patient.qdmPatient.dataElements.collect { |de| de if de.qdmCategory == 'patient_characteristic' }.compact
      patient.qdmPatient.dataElements.keep_if { |de| data_element_used_by_measure(de) }
      patient.qdmPatient.dataElements.each do |data_element|
        # keep if data_element code and codesystem is in one of the relevant_codes
        data_element.dataElementCodes.keep_if { |de_code| @relevant_codes.include?(code: de_code.code, codeSystemOid: de_code.codeSystemOid) }
        # Do not try to replace with negated valueset if all codes are removed
        next if data_element.dataElementCodes.blank?

        replace_negated_code_with_valueset(data_element) if data_element.respond_to?('negationRationale') && data_element.negationRationale
      end
      # keep data element if codes is not empty
      patient.qdmPatient.dataElements.keep_if { |data_element| data_element.dataElementCodes.present? }
      patient.qdmPatient.dataElements.concat(demographic_criteria)
      patient
    end

    private

    def data_element_category_and_status(data_element)
      { category: data_element.qdmCategory, status: data_element['qdmStatus'] }
    end

    # returns true if a patients data element is used by a measure
    def data_element_used_by_measure(data_element)
      @de_category_statuses_for_measures.include?(category: data_element['qdmCategory'], status: data_element['qdmStatus'])
    end

    def replace_negated_code_with_valueset(data_element)
      de = data_element
      neg_vs = @valuesets.select { |vs| vs.concepts.any? { |c| c.code == de.codes.first.code && c.code_system_oid == de.codes.first.codeSystemOid } }
      # If more than one valueset (in the measures uses the code, it is not possible for scoop and filter to know which valueset to negate)
      return if neg_vs.size > 1

      negated_valueset = neg_vs.first
      # If the first three characters of the valueset oid is drc, this is a direct reference code, not a valueset.  Do not negate a valueset here.
      return if negated_valueset.oid[0, 3] == 'drc'

      data_element.dataElementCodes = [{ code: negated_valueset.oid, codeSystemOid: '1.2.3.4.5.6.7.8.9.10' }]
    end
  end
end
