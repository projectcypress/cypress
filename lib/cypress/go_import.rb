module Cypress
  module GoImport
    def self.replace_negated_codes(record, bundle)
      record.entries.each do |entry|
        if entry.negationInd && entry.codes.key?('NA_VALUESET') && entry.codes.size == 1
          select_negated_code(entry, bundle)
        end
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
