module Cypress
  class ScoopAndFilter
    def initialize(measures)
      @relevant_codes = codes_in_measures(measures)
      @demographic_oids = get_demo_category_status(measures)
      @de_category_status_for_measures = get_all_category_status(measures) - get_demo_category_status(measures)
    end

    # return an array of all of the concepts in all of the valueset for the measure
    def codes_in_measures(measures)
      valuesets = measures.collect(&:value_sets).flatten
      code_list = valuesets.collect(&:concepts).flatten
      code_list.map { |cl| { code: cl.code, codeSystem: cl.code_system_name } }
    end

    def get_demo_category_status(measures)
      measures.collect do |measure|
        measure.source_data_criteria.map { |cr| data_element_category_and_status(cr) if cr.qdmCategory == 'patient_characteristic' }
      end.flatten.uniq
    end

    def get_all_category_status(measures)
      measures.collect do |measure|
        measure.source_data_criteria.map { |cr| data_element_category_and_status(cr) }
      end.flatten.uniq
    end

    def scoop_and_filter(patient)
      demographic_criteria = patient.qdmPatient.dataElements.collect { |de| de if de.qdmCategory == 'patient_characteristic' }.compact
      patient.qdmPatient.dataElements.keep_if { |de| data_element_used_by_measure(de) }
      patient.qdmPatient.dataElements.each do |data_element|
        # keep if data_element code and codesystem is in one of the relevant_codes
        data_element.dataElementCodes.keep_if { |de_code| @relevant_codes.include?(code: de_code.code, codeSystem: de_code.codeSystem) }
      end
      # keep data element if codes is not empty
      patient.qdmPatient.dataElements.keep_if { |data_element| data_element.dataElementCodes.present? }
      patient.qdmPatient.dataElements.concat(demographic_criteria)
      patient
    end

    private

    def data_element_category_and_status(data_element)
      # if a data element does not have a status, only return the category
      return { category: data_element.qdmCategory, status: nil } unless data_element['qdmStatus']

      { category: data_element.qdmCategory, status: data_element.qdmStatus }
    end

    # returns true if a patients data element is used by a measure
    def data_element_used_by_measure(data_element)
      @de_category_status_for_measures.include?(category: data_element['qdmCategory'], status: data_element['qdmStatus'])
    end
  end
end
