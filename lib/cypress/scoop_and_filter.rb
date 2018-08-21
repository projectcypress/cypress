module Cypress
  class ScoopAndFilter
    def initialize(measures)
      @relevant_codes = codes_in_measures(measures)
      @demographic_oids = ['2.16.840.1.113883.10.20.28.3.55', '2.16.840.1.113883.10.20.28.3.59', '2.16.840.1.113883.10.20.28.3.57',
                           '2.16.840.1.113883.10.20.28.3.56', '2.16.840.1.113883.10.20.28.3.54']
      @hqmf_oids_for_measures = get_all_hqmf_oids_definition_and_status(measures) - @demographic_oids
    end

    # return an array of all of the concepts in all of the valueset for the measure
    def codes_in_measures(measures)
      valuesets = measures.collect do |measure|
        measure['value_set_oid_version_objects'].collect do |valueset|
          ValueSet.where(oid: valueset.oid, version: valueset.version).to_a
        end
      end.flatten
      code_list = valuesets.collect(&:concepts).flatten
      code_list.map { |cl| { code: cl.code, codeSystem: cl.code_system_name } }
    end

    def get_all_hqmf_oids_definition_and_status(measures)
      measures.collect do |measure|
        measure.source_data_criteria.collect do |_key, criteria|
          HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids.get_all_hqmf_oids(criteria['definition'], criteria['status'])
        end
      end.flatten.uniq
    end

    def scoop_and_filter(patient)
      demographic_criteria = patient.dataElements.where(hqmfOid: { '$in' => @demographic_oids }).clone
      patient.dataElements.keep_if { |data_element| @hqmf_oids_for_measures.include? data_element.hqmfOid }
      patient.dataElements.each do |data_element|
        # keep if data_element code and codesystem is in one of the relevant_codes
        data_element.dataElementCodes.keep_if { |de_code| @relevant_codes.include?(code: de_code.code, codeSystem: de_code.codeSystem) }
      end
      # keep data element if codes is not empty
      patient.dataElements.keep_if { |data_element| data_element.dataElementCodes.present? }
      patient.dataElements.concat(demographic_criteria)
      patient
    end
  end
end
