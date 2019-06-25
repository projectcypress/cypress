module Cypress
  module QRDAPostProcessor
    def self.replace_negated_codes(patient, bundle)
      patient.qdmPatient.dataElements.each do |de|
        select_negated_code(de, bundle) if de['negationRationale'] && de.codes.find { |c| c.codeSystemOid == '1.2.3.4.5.6.7.8.9.10' }
      end
    end

    def self.select_negated_code(data_element, bundle)
      negated_element = data_element.dataElementCodes.map { |dec| dec if dec.codeSystemOid == '1.2.3.4.5.6.7.8.9.10' }.first
      negated_vs = negated_element.code
      # If Cypress has a default code selected, use it.  Otherwise, use the first in the valueset.
      code = if bundle.default_negation_codes && bundle.default_negation_codes[negated_vs]
               { code: bundle.default_negation_codes[negated_vs]['code'],
                 codeSystemOid: bundle.default_negation_codes[negated_vs]['codeSystem'] }
             else
               valueset = ValueSet.where(oid: negated_vs, bundle_id: bundle.id)
               { code: valueset.first.concepts.first['code'], codeSystemOid: valueset.first.concepts.first['code_system_oid'] }
             end
      data_element.dataElementCodes << code
    end
  end
end
