module Cypress
  module GoImport
    def self.replace_negated_codes(patient, bundle)
      patient.dataElements.each do |de|
        select_negated_code(de, bundle) if de['negationRationale'] && de.codes.find { |c| c.codeSystem == 'NA_VALUESET' }
      end
    end

    def self.select_negated_code(data_element, bundle)
      negated_element = data_element.dataElementCodes.map { |dec| dec if dec.codeSystem == 'NA_VALUESET' }.first
      negated_vs = negated_element.code
      # If Cypress has a default code selected, use it.  Otherwise, use the first in the valueset.
      negated_code = if bundle.default_negation_codes && bundle.default_negation_codes[negated_vs]
                       QDM::Code.new(bundle.default_negation_codes[negated_vs]['code'], bundle.default_negation_codes[negated_vs]['codeSystem'])
                     else
                       valueset = ValueSet.where(oid: negated_vs, bundle_id: bundle.id)
                       QDM::Code.new(valueset.first.concepts.first['code'], valueset.first.concepts.first['code_system_name'])
                     end
      data_element.dataElementCodes << negated_code
    end
  end
end
