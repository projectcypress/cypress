module Cypress
  module GoImport
    def self.update_conditions(record)
      record.conditions.each do |condition|
        if condition.status_code['HL7 ActStatus'] && condition.status_code['HL7 ActStatus'][0] == ''
          condition.status_code['HL7 ActStatus'][0] = nil
        end
        condition[:end_time] = nil if condition[:end_time].nil?
      end
    end

    def self.resolve_references(record)
      refs = []
      record.entries.each do |entry|
        entry.references.each do |ref|
          ref.referenced_id = ref.exported_ref
          refs << ref.exported_ref
        end
      end
      refs
    end

    def self.update_entries(record, bundle, refs)
      record.entries.each do |entry|
        entry._id = if refs.include?(entry.cda_identifier.extension)
                      BSON::ObjectId.from_string(entry.cda_identifier.extension)
                    else
                      entry.cda_identifier._id
                    end
        # If the entry is negated, there is a NA codeset and there is only one code, find a code to use for calcuation
        select_negated_code(entry, bundle) if entry.negationInd && entry.codes.key?('NA_VALUESET') && entry.codes.size == 1
      end
    end

    def self.select_negated_code(entry, bundle)
      negated_vs = entry.codes['NA_VALUESET'].first
      # If Cypress has a default code selected, use it.  Otherwise, use the first in the valueset.
      if bundle.default_negation_codes && bundle.default_negation_codes[negated_vs]
        entry.add_code(bundle.default_negation_codes[negated_vs]['code'], bundle.default_negation_codes[negated_vs]['codeSystem'])
      else
        valueset = HealthDataStandards::SVS::ValueSet.where(oid: entry.codes['NA_VALUESET'].first, bundle_id: bundle.id)
        entry.add_code(valueset.first.concepts.first['code'], valueset.first.concepts.first['code_system_name'])
      end
    end
  end
end
