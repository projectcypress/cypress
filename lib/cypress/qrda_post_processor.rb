module Cypress
  module QRDAPostProcessor
    # checks for placeholder negation code_system
    def self.replace_negated_codes(patient, bundle)
      patient.qdmPatient.dataElements.each do |de|
        select_negated_code(de, bundle) if de['negationRationale'] && de.codes.find { |c| c.codeSystemOid == '1.2.3.4.5.6.7.8.9.10' }
      end
    end

    # use "code" (which is used to store the valuset) to find an appropriate actual code to use for calculation
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

    # create an issue message for any negations that are done with a single code rather than vs
    def self.issues_for_negated_single_codes(patient, bundle, measures)
      drc_codes = ValueSet.where(oid: /drc/i).map { |vs| vs.concepts.first.code }
      error_list = []
      patient.qdmPatient.dataElements.each do |de|
        next unless de['negationRationale']

        de.codes.each do |c|
          next unless c.codeSystemOid != '1.2.3.4.5.6.7.8.9.10' && !drc_codes.include?(c)

          # pull relevant measures from patient if possible
          vs_ids = measures.map(&:value_set_ids).flatten.unique
          potential_vs = ValueSet.where(:id.in => vs_ids, 'concepts.code' => c.code, bundle_id: bundle._id).map(&:oid)
          msg = 'CMS QRDA Implementation Guide, Section 5.2.3.1, “Not Done” with a Reason: ' \
                'Must provide the value set OID instead of a specific code from the value set. ' \
                'Set the code attribute code/sdtc:valueset="[VSAC value set OID]" ' \
                "Valuesets for code #{c.code} that may be relevant for this test include: #{potential_vs.join(', ')}"
          error_list << msg
        end
      end
      error_list
    end
  end
end
