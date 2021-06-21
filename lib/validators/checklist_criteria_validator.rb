# frozen_string_literal: true

# require "cypress/qrda_file_validator"

module Validators
  class ChecklistCriteriaValidator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators

    def initialize(checklist_test)
      @criteria_list = checklist_test.checked_criteria
      @criteria_list.each do |criteria|
        # set passing flag to false during each validation
        criteria.passed_qrda = false
        criteria.save!
      end
      @qrda_version = checklist_test.bundle.qrda_version
    end

    # Validates a QRDA Cat I file.  This routine will validate the file against the checklist criteria
    def validate(file, _options = {})
      @file = file
      # parse the cat 1 file into the patient model
      patient, _warnings = QRDA::Cat1::PatientImporter.instance.parse_cat1(@file)
      # iterate through each criteria to see if it is contained in the patient
      @criteria_list.each do |criteria|
        # if a criteria has already passed, no need to check again
        next if criteria.passed_qrda

        patient.normalize_date_times
        if validate_criteria(criteria, patient.qdmPatient)
          criteria.passed_qrda = true
          criteria.save
        end
      end
    end

    private

    # see if the checked criteria in the imported patient
    def validate_criteria(checked_criteria, patient)
      sdc = checked_criteria.source_data_criteria

      # get all data elements for the specified source data criteria
      data_elements = patient.get_data_elements(sdc['qdmCategory'], sdc['qdmStatus'])
      # get the attribute specified for the Record Sample test (e.g., authorDatetime)
      attribute = checked_criteria.attribute_index ? sdc['dataElementAttributes'][checked_criteria.attribute_index]['attribute_name'] : nil
      # see if any of the data elements have the attribute (with a value) specified in the Record Sample test
      data_elements_that_meet_criteria(data_elements, checked_criteria, attribute).length.positive?
    end

    def data_elements_that_meet_criteria(data_elements, checked_criteria, attribute)
      checked_code = if checked_criteria['negated_valueset']
                       # the checked "code" should be the direct reference code, or the valueset oid
                       drc_or_valueset_oid(checked_criteria['selected_negated_valueset'])
                     else
                       checked_criteria['code']
                     end
      de_with_code = data_elements.keep_if { |de| de.dataElementCodes.map(&:code).include?(checked_code) }
      return de_with_code.keep_if { |de| attribute_has_data(extract_attribute_from_data_element(de, attribute), checked_criteria) } if attribute

      de_with_code
    end

    # if the oid is for a direct reference code, return the code.  if the oid is for a valueset, return the oid
    def drc_or_valueset_oid(oid)
      oid[0, 3] == 'drc' ? ValueSet.where(oid: oid).first.concepts.first.code : oid
    end

    # This method will return true if the specified attribute has a stored value
    def attribute_has_data(attribute, checked_criteria)
      # If the attribute is a Time, DateTime or an Integer, it was stored correctly
      return true if attribute.is_a? Time
      return true if attribute.is_a? DateTime
      return true if attribute.is_a? Integer
      return true if attribute.is_a? Float
      return true if attribute.is_a? String
      # If the attribute is an Array, loop through the array
      return attribute.any? { |at| attribute_has_data(at, checked_criteria) } if attribute.is_a? Array

      # If the attribute is a QDM Type, investigate further
      confirm_qdm_type_have_contents(attribute, checked_criteria)
    end

    def extract_attribute_from_data_element(data_element, attribute_name)
      attribute = data_element[attribute_name]
      attribute ||= data_element.send(attribute_name)
      attribute
    end

    def confirm_qdm_type_have_contents(attribute, checked_criteria)
      # Return false if no attribute is not passed in
      return false unless attribute
      return verify_code_attribute(attribute, checked_criteria) if attribute.is_a? QDM::Code
      return verify_component_attribute(attribute, checked_criteria) if attribute.is_a? QDM::Component
      return verify_dx_component_attribute(attribute, checked_criteria) if attribute.is_a? QDM::DiagnosisComponent
      return verify_id_attribute(attribute) if attribute.is_a? QDM::Identifier
      return verify_interval_attribute(attribute) if attribute.is_a? QDM::Interval
      return verify_facility_location_attribute(attribute, checked_criteria) if attribute.is_a? QDM::FacilityLocation
      return verify_quantity_attribute(attribute) if attribute.is_a? QDM::Quantity
      return verify_entity_attribute(attribute) if attribute.is_a? QDM::Entity
      return verify_ratio_attribute(attribute) if attribute.is_a? QDM::Ratio

      # If above are all passed, the type might be an Any type.  perform checks using ._type
      confirm_any_types(attribute, checked_criteria)
    end

    def confirm_any_types(attribute, checked_criteria)
      return verify_code_attribute(attribute, checked_criteria) if attribute._type == 'QDM::Code'
      return verify_component_attribute(attribute, checked_criteria) if attribute._type == 'QDM::Component'
      return verify_dx_component_attribute(attribute, checked_criteria) if attribute._type == 'QDM::DiagnosisComponent'
      return verify_id_attribute(attribute) if attribute._type == 'QDM::Identifier'
      return verify_interval_attribute(attribute) if attribute._type == 'QDM::Interval'
      return verify_facility_location_attribute(attribute, checked_criteria) if attribute._type == 'QDM::FacilityLocation'
      return verify_quantity_attribute(attribute) if attribute._type == 'QDM::Quantity'

      entity_types = ['QDM::Entity', 'QDM::CarePartner', 'QDM::Organization', 'QDM::PatientEntity', 'QDM::Practitioner']
      return verify_entity_attribute(attribute) if entity_types.include? attribute._type
      return verify_ratio_attribute(attribute) if attribute._type == 'QDM::Ratio'

      # Return false if no checks pass
      false
    end

    def verify_code_attribute(attribute, checked_criteria)
      # If a attribute_code is specified in the checked_criteria (i.e., filled in the Record Sample Form) make sure it matches
      return attribute.code == checked_criteria['attribute_code'] if checked_criteria['attribute_code']

      # If a attribute_code is not specified in the checked_criteria (i.e., filled in the Record Sample Form) make any code is there
      !attribute.code.nil?
    end

    def verify_component_attribute(attribute, checked_criteria)
      # A component has nested attributes, check those
      attribute_has_data(attribute.result, checked_criteria)
    end

    def verify_dx_component_attribute(attribute, checked_criteria)
      # A component has nested attributes, check those
      attribute_has_data(attribute.code, checked_criteria)
    end

    def verify_id_attribute(attribute)
      # An id attribute should have (at a minimum) a 'value' value
      !attribute.value.nil?
    end

    def verify_interval_attribute(attribute)
      # An interval attribute should have (at a minimum) a 'low' value
      !attribute.low.nil?
    end

    def verify_facility_location_attribute(attribute, checked_criteria)
      # If a attribute_code is specified in the checked_criteria (i.e., filled in the Record Sample Form) make sure it matches
      return attribute.code.code == checked_criteria['attribute_code'] if checked_criteria['attribute_code']

      # If a attribute_code is not specified in the checked_criteria (i.e., filled in the Record Sample Form) make any code is there
      !attribute.code.nil?
    end

    def verify_entity_attribute(attribute)
      # An entity attribute should have (at a minimum) an 'identifier' value
      !attribute.identifier.nil?
    end

    def verify_quantity_attribute(attribute)
      # An quantity attribute should have (at a minimum) a 'value' value
      !attribute.value.nil?
    end

    def verify_ratio_attribute(attribute)
      # An ratio attribute should have (at a minimum) a 'denominator' value
      !attribute.denominator.nil?
    end
  end
end
