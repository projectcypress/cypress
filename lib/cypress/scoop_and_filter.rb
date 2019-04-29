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
          HealthDataStandards::SVS::ValueSet.where(oid: valueset.oid, version: valueset.version).to_a
        end
      end.flatten
      code_list = valuesets.collect(&:concepts).flatten
      code_list.map { |cl| { code: cl.code, codeSystem: cl.code_system_name } }
    end

    def get_all_hqmf_oids_definition_and_status(measures)
      measures.collect do |measure|
        measure.source_data_criteria.collect do |_key, criteria|
          get_all_hqmf_oids(criteria['definition'], criteria['status'])
        end
      end.flatten.uniq
    end

    def get_all_hqmf_oids(definition, status)
      version_negation_combinations = [{ version: 'r1', negation: false },
                                       { version: 'r1', negation: true },
                                       { version: 'r2', negation: false },
                                       { version: 'r2cql', negation: false }]
      hqmf_oids = version_negation_combinations.collect do |obj|
        HQMF::DataCriteria.template_id_for_definition(definition, status, obj.negation, obj.version)
      end
      hqmf_oids
    end

    def scoop_and_filter(patient)
      demographic_criteria = patient.dataElements.where(hqmfOid: { '$in' => @demographic_oids }).clone
      patient.dataElements.keep_if { |data_element| @hqmf_oids_for_measures.include? data_element.hqmfOid }
      patient.dataElements.each do |data_element|
        # keep if data_element code and codesystem is in one of the relevant_codes
        data_element.dataElementCodes.keep_if { |de_code| @relevant_codes.include?(code: de_code.code, codeSystem: de_code.codeSystem) }
        # Do not try to replace with negated valueset if all codes are removed
        next if data_element.dataElementCodes.blank?
        replace_negated_code_with_valueset(data_element) if data_element.respond_to?('negationRationale') && data_element.negationRationale
      end
      # keep data element if codes is not empty
      patient.dataElements.keep_if { |data_element| data_element.dataElementCodes.present? }
      patient.dataElements.concat(demographic_criteria)
      patient
    end

    private

    def replace_negated_code_with_valueset(data_element)
      negated_valuesets = HealthDataStandards::SVS::ValueSet.where('concepts.code': data_element.codes.first.code,
                                                                   'concepts.code_system_name': data_element.codes.first.codeSystem)
      # If more than one valueset (in the measures uses the code, it is not possible for scoop and filter to know which valueset to negate)
      return if negated_valuesets.size > 1
      negated_valueset = negated_valuesets.first
      # If the first three characters of the valueset oid is drc, this is a direct reference code, not a valueset.  Do not negate a valueset here.
      return if negated_valueset.oid[0, 3] == 'drc'
      data_element.dataElementCodes = [{ code: negated_valueset.oid, codeSystem: 'NA_VALUESET' }]
    end
  end
end
