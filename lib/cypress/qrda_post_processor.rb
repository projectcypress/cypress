module Cypress
  module QRDAPostProcessor
    # checks for placeholder negation code_system
    def self.replace_negated_codes(patient, bundle)
      patient.qdmPatient.dataElements.each do |de|
        select_negated_code(de, bundle) if de['negationRationale'] && de.codes.find { |c| c.system == '1.2.3.4.5.6.7.8.9.10' }
      end
    end

    def self.build_code_descriptions(codes, patient, bundle)
      codes.each do |code|
        code_only, code_system = code.split(':')
        if code_system == '1.2.3.4.5.6.7.8.9.10'
          # find valueset description
          description = ValueSet.where(oid: code_only, bundle_id: bundle.id).first&.display_name
          Rails.logger.warn "ValueSet #{code_only} not found for Bundle #{bundle.id}" if description.nil?
        else
          # ValueSet.find_by may be more efficient if there are performance concerns, but may need to handle Mongoid::Errors::DocumentNotFound
          concepts = ValueSet.where('concepts.code' => code_only, 'concepts.code_system_oid' => code_system, bundle_id: bundle.id).first&.concepts
          description = concepts&.detect { |x| code == "#{x.code}:#{x.code_system_oid}" }&.display_name
          Rails.logger.warn "Code #{code_only}, System #{code_system} not found for Bundle #{bundle.id}" if description.nil?
        end
        # mongo keys cannot contain '.', so replace all '.', key example: '21112-8:2_16_840_1_113883_6_1'
        patient.code_description_hash[code.tr('.', '_')] = description
      end
    end

    # use "code" (which is used to store the valuset) to find an appropriate actual code to use for calculation
    def self.select_negated_code(data_element, bundle)
      negated_element = data_element.dataElementCodes.map { |dec| dec if dec.system == '1.2.3.4.5.6.7.8.9.10' }.first
      negated_vs = negated_element.code
      # If Cypress has a default code selected, use it.  Otherwise, use the first in the valueset.
      code = if bundle.default_negation_codes && bundle.default_negation_codes[negated_vs]
               { code: bundle.default_negation_codes[negated_vs]['code'],
                 system: bundle.default_negation_codes[negated_vs]['codeSystem'] }
             else
               valueset = ValueSet.where(oid: negated_vs, bundle_id: bundle.id)
               return if valueset.empty?

               { code: valueset.first.concepts.first['code'], system: valueset.first.concepts.first['code_system_oid'] }
             end
      data_element.dataElementCodes << code
      code
    end

    # create an issue message for any negations that are done with a single code rather than vs
    def self.issues_for_negated_single_codes(patient, bundle, measures)
      drc_codes = ValueSet.where(oid: /drc/i).map { |vs| vs.concepts.first.code }
      error_list = []
      patient.qdmPatient.dataElements.each do |de|
        next unless de['negationRationale']

        de.codes.each do |c|
          next unless c.system != '1.2.3.4.5.6.7.8.9.10' && !drc_codes.include?(c.code)

          # pull relevant measures from patient if possible
          vs_ids = measures.map(&:value_set_ids).flatten.uniq
          potential_vs = ValueSet.where(:id.in => vs_ids, 'concepts.code' => c.code, bundle_id: bundle._id).map(&:oid)
          vs_list = potential_vs.empty? ? 'None' : potential_vs.join(', ')
          msg = 'CMS QRDA Implementation Guide, Section 5.2.3.1, “Not Done” with a Reason: ' \
                'Must provide the value set OID instead of a specific code from the value set. ' \
                'Set the code attribute code/sdtc:valueset="[VSAC value set OID]" ' \
                "Valuesets for code #{c.code} that may be relevant for this test include: #{vs_list}"
          error_list << msg
        end
      end
      error_list
    end

    def self.issues_for_mismatched_units(patient, bundle, measures)
      error_list = []
      # only a limited set of units need to be checked for matches
      APP_CONSTANTS['unit_matches'].each do |match|
        next unless measures.any? { |m| m.hqmf_set_id == match['hqmf_set_id'] }

        valueset = bundle.value_sets.where(oid: match['code_list_id']).first
        if valueset.nil?
          Rails.logger.warn "ValueSet #{match['code_list_id']} not found"
          next
        end
        patient.qdmPatient.dataElements.each do |de|
          # check for matching data element type and code in valueset
          next unless de._type == match['de_type'] && de.dataElementCodes.any? { |dec| valueset.concepts.any? { |conc| conc.code == dec.code } }
          # check that the data element has a result value
          next unless de.result

          msg = unit_error_message(de, match, valueset)
          error_list << msg if msg
        end
      end
      error_list
    end

    def self.unit_error_message(data_element, expected_unit, valueset)
      data_element_title = "#{data_element._type} (#{valueset.display_name})"
      # If a unit is not specified in the QRDA, it is imported as an Integer or Float.
      if (data_element.result.is_a? Integer) || (data_element.result.is_a? Float)
        "Unspecified unit for #{data_element_title} does not match expected units (#{expected_unit['units'].join(', ')}). " \
        'Units must match measure-defined units. '
      # If a unit is specified in the QRDA, it is imported as a Quantity.  Check the Quantity's unit
      elsif data_element.result._type == 'QDM::Quantity' && !expected_unit['units'].include?(data_element.result.unit)
        "Unit '#{data_element.result.unit}' for #{data_element_title} does not match expected units (#{expected_unit['units'].join(', ')}). " \
        'Units must match measure-defined units. '
      end
    end

    def self.remove_telehealth_encounters(patient, codes_modifiers, warnings, ineligible_measures)
      codes_modifiers.each do |encounter_id, codes_modifier|
        # Exclude encounter for appropriate qualifier name 'VR' or value (from config)
        has_telehealth_value = APP_CONSTANTS['telehealth_modifier_codes'].include? codes_modifier[:value]&.code
        has_telehealth_name = codes_modifier[:name]&.code == 'VR'
        next unless has_telehealth_value || has_telehealth_name

        telehealth_encounter = patient.qdmPatient.encounters.where(_id: encounter_id)
        qualifier_value = has_telehealth_value ? codes_modifier[:value]&.code : codes_modifier[:name]&.code
        ineligible_measures_ids = ineligible_measures.pluck('cms_id').join(', ')
        msg = "Telehealth encounter #{telehealth_encounter.first.codes.first.code} with modifier " \
              "#{qualifier_value} not used in calculation for eCQMs (#{ineligible_measures_ids}) that are not eligible for telehealth."
        warnings << ValidationError.new(message: msg,
                                        location: codes_modifier[:xpath_location])
        telehealth_encounter.delete
      end
    end
  end
end
