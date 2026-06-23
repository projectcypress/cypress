# frozen_string_literal: true

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
      code_list.map { |cl| { code: cl.code, system: cl.code_system_oid } }
    end

    def get_non_demographic_category_statuses(measures)
      measures.collect do |measure|
        measure.source_data_criteria.map { |cr| data_element_category_and_status(cr) unless cr.qdmCategory == 'patient_characteristic' }
      end.flatten.uniq.compact
    end

    def scoop_and_filter(patient, replace_negations: true, persist_scoop: false)
      de_to_delete = []
      de_to_delete += patient.qdmPatient.dataElements.map { |de| de unless data_element_used_by_measure(de) }
      patient.qdmPatient.dataElements.each do |data_element|
        scoop_and_filter_data_element_codes(data_element, persist_scoop)
      end
      # keep data element if codes is not empty
      de_to_delete += patient.qdmPatient.dataElements.map { |de| de unless de.dataElementCodes.present? }
      if persist_scoop
        de_to_delete.compact.each(&:destroy)
      else
        ids_to_delete = de_to_delete.compact.map(&:id)
        patient.qdmPatient.dataElements.keep_if { |data_element| !ids_to_delete.include?(data_element.id) }
      end
      replace_negated_codes_with_valueset(patient) if replace_negations
      patient
    end

    def replace_negated_codes_with_valueset(patient)
      # If a negated code belongs to multiple valuesets, we need to add a cloned entry for each valueset.
      # This array stores the cloned entries to be added
      multi_vs_negation_elements = []
      ids_to_delete = []
      patient.qdmPatient.dataElements.each do |data_element|
        next unless data_element.respond_to?('negationRationale') && data_element.negationRationale

        replace_negated_code_with_valueset(data_element, multi_vs_negation_elements)
        if data_element.dataElementCodes.blank?
          ids_to_delete << data_element.id
          next
        end

        # add data element valueset and other potentially relevant valueset descriptions
        codes = (multi_vs_negation_elements + [data_element]).map { |de| "#{de.dataElementCodes.first.code}:#{de.dataElementCodes.first.system}" }
        Cypress::QrdaPostProcessor.build_code_descriptions(codes, patient, patient.bundle)
      end
      patient.qdmPatient.dataElements.concat(multi_vs_negation_elements)
      patient.qdmPatient.dataElements.keep_if { |data_element| !ids_to_delete.include?(data_element.id) }
      patient
    end

    private

    # Method to remove codes from a data element that are not relevant to measure.
    # Multi_vs_negation_elements is an array of cloned elements to add to patient record to capture all of the negated valuesets
    def scoop_and_filter_data_element_codes(data_element, persist_scoop)
      return if data_element.qdmCategory == 'patient_characteristic'

      # keep if data_element code and codesystem is in one of the relevant_codes
      # Also keep all negated valuesets, we'll deal with those later
      data_element.dataElementCodes.keep_if do |de_code|
        relevant_code?(de_code) || de_code.system == '1.2.3.4.5.6.7.8.9.10'
      end
      # Return if all codes have been removed
      return if data_element.dataElementCodes.blank?

      scoop_and_filter_data_element_fields(data_element)
      # For repeatability, don't do this if you are saving the record
      remove_irrelevant_valuesets_and_add_description_to_data_element(data_element) unless persist_scoop
    end

    def scoop_and_filter_data_element_fields(data_element)
      # Iterate through each field to see coded fields include relevant codes
      data_element.fields.keys.each do |field_name|
        next if data_element[field_name].nil?

        # Dianoses and Facility Locations are unique because they are arrays
        if field_name == 'diagnoses'
          data_element.diagnoses.keep_if do |diagnosis|
            relevant_code?(diagnosis.code)
          end
          data_element.diagnoses = nil if data_element.diagnoses.blank?
        elsif field_name == 'facilityLocations'
          data_element.facilityLocations.keep_if do |facility_location|
            relevant_code?(facility_location.code)
          end
          data_element.facilityLocations = nil if data_element.facilityLocations.blank?
        end
        next unless data_element.fields[field_name].type == QDM::Code

        data_element[field_name] = nil unless relevant_code?(data_element[field_name])
      end
    end

    def relevant_code?(code)
      @relevant_codes.include?(code: code.code, system: code.system)
    end

    def data_element_category_and_status(data_element)
      { category: data_element.qdmCategory, status: data_element['qdmStatus'], oid: data_element['codeListId'] }
    end

    # returns true if a patients data element is used by a measure
    def data_element_used_by_measure(data_element)
      return true if data_element.qdmCategory == 'patient_characteristic'

      !@de_category_statuses_for_measures.index do |dcs|
        dcs[:category] == data_element['qdmCategory'] && dcs[:status] == data_element['qdmStatus']
      end.nil?
    end

    def remove_irrelevant_valuesets_and_add_description_to_data_element(data_element)
      de = data_element
      vsets = if de.codes.any? { |code| code.system == '1.2.3.4.5.6.7.8.9.10' }
                @valuesets.select { |vs| vs.oid == de.codes.select { |code| code.system == '1.2.3.4.5.6.7.8.9.10' }.first.code }
              else
                @valuesets.select { |vs| vs.concepts.any? { |c| c.code == de.codes.first.code && c.code_system_oid == de.codes.first.system } }
              end
      # A data element may have codes from multiple valusets, pick the first valueset for the description
      if vsets.blank?
        de.dataElementCodes.clear
        return
      end

      vs = vsets.first
      de.description = vs.display_name
    end

    def value_set_appropriate_for_data_element(data_element, valueset_oid)
      @de_category_statuses_for_measures.include?(category: data_element['qdmCategory'], status: data_element['qdmStatus'], oid: valueset_oid)
    end

    # For negated elements, replace codes (that aren't direct reference codes) with valuesets.
    # If a code is in multiple valuesets, create new entries to be added to record
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def replace_negated_code_with_valueset(data_element, multi_vs_negation_elements)
      de = data_element
      # If the data element already knows the negated valueset, use it
      if de.codes.any? { |code| code.system == '1.2.3.4.5.6.7.8.9.10' }
        # Remove the 'assumed' code for the valueset.  This assumed code is only used for calculation, not display.
        de.dataElementCodes.keep_if { |code| code.system == '1.2.3.4.5.6.7.8.9.10' }
        return
      end
      neg_vs = @valuesets.select { |vs| vs.concepts.any? { |c| c.code == de.codes.first.code && c.code_system_oid == de.codes.first.system } }
      neg_vs.keep_if { |nvs| value_set_appropriate_for_data_element(de, nvs.oid) }

      if neg_vs.blank?
        de.dataElementCodes.clear
        return
      end

      negated_valueset = neg_vs.first
      neg_vs.drop(1).each do |additional_vs|
        next if additional_vs.oid[0, 3] == 'drc'

        de_for_additional_vs = data_element.clone
        # Create Ids from the source data element and the valueset so they remain consistent
        id_string = BSON::ObjectId.from_data("#{data_element.id}#{additional_vs.id}").to_s
        # When using BSON::ObjectId.from_data with the two ids, the untrimmed ids are 96 characters. 2 examples below
        # 363464653166616166396130313063376433386365313337363464653166616166396130313063376433386365313338
        # 363464653166623566396130313063376433386365313339363464653166623566396130313063376433386365313361
        # Selective slicing to 36 characters still results in unique ids like,
        # 653166616163653133376661616365313338
        # 653166623563653133396662356365313361
        de_for_additional_vs.id = id_string[6, 10] + id_string[38, 10] + id_string[58, 6] + id_string[86, 10]
        de_for_additional_vs.dataElementCodes = [{ code: additional_vs.oid, system: '1.2.3.4.5.6.7.8.9.10' }]
        multi_vs_negation_elements << de_for_additional_vs
      end

      # If the first three characters of the valueset oid is drc, this is a direct reference code, not a valueset.  Do not negate a valueset here.
      return if negated_valueset.oid[0, 3] == 'drc'

      data_element.dataElementCodes = [{ code: negated_valueset.oid, system: '1.2.3.4.5.6.7.8.9.10' }]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
