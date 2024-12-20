# frozen_string_literal: true

# require "cypress/qrda_file_validator"

module Validators
  class ProgramCriteriaValidator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators
    include QrdaHelper

    def initialize(program_test)
      @criteria_list = program_test.program_criteria
      @criteria_list.each do |criteria|
        # set passing flag to false during each validation
        criteria.criterion_verified = false
        criteria.save!
      end
    end

    # Validates a QRDA Cat I file.  This routine will validate the file against the checklist criteria
    def validate(file, options = {})
      @file = file
      @doc = get_document(file)
      # Perform measure calculation for uploaded Cat I files
      import_patient(options, measure_ids_from_cat_1_file(@doc)) if options.task.product_test.reporting_program_type == 'eh'
      # Validate to correct HQMF ids are being reported
      add_cqm_validation_error_as_execution_error(Cat1Measure.instance.validate(@doc, file_name: options[:file_name]),
                                                  'CqmValidators::Cat1Measure',
                                                  :xml_validation)
      @criteria_list.each do |criteria|
        # if a criteria has already passed, no need to check again
        next if criteria.criterion_verified

        next unless validate_criteria(criteria)

        criteria.criterion_verified = true
        criteria.file_name = options[:file_name]
        criteria.save
      end
    end

    def import_patient(options, measure_ids)
      patient, warnings, _codes, codes_modifiers = QRDA::Cat1::PatientImporter.instance.parse_cat1(@file)
      persisible_codes_modifiers = {}
      codes_modifiers.each { |key, cm| persisible_codes_modifiers[key.to_s] = cm }
      patient.update(_type: CQM::TestExecutionPatient, correlation_id: options.test_execution.id.to_s, codes_modifiers: persisible_codes_modifiers,
                     reported_measure_hqmf_ids: measure_ids, file_name: options[:file_name])
      post_processsor_check(patient, options)
      patient.save!
      warnings.each { |e| add_warning e.message, file_name: options[:file_name], location: e.location }
    end

    def post_processsor_check(patient, options)
      # Do not perform these validations if only running against the HL7 schematron
      unless options.task.product_test.cms_program == 'HL7_Cat_I'
        patient_has_pcp_and_other_element(patient, options)
        # check for single code negation errors
        errors = Cypress::QrdaPostProcessor.issues_for_negated_single_codes(patient, options.task.bundle, options.task.product_test.measures)
        unit_errors = Cypress::QrdaPostProcessor.issues_for_mismatched_units(patient, options.task.bundle, options.task.product_test.measures)
        errors.each { |e| add_error e, file_name: options[:file_name] }
        unit_errors.each { |e| add_error e, file_name: options[:file_name] }
      end
      Cypress::QrdaPostProcessor.replace_negated_codes(patient, options.task.bundle)
      Cypress::QrdaPostProcessor.remove_invalid_qdm_56_data_types(patient) if options.task.bundle.major_version.to_i > 2021
    end

    # Check that a patient as a patient_characteristic_payer and atleast 1 other (non-demographic) data criteria
    def patient_has_pcp_and_other_element(patient, options)
      patient_characteristic_types = ['QDM::PatientCharacteristicPayer',
                                      'QDM::PatientCharacteristicBirthdate',
                                      'QDM::PatientCharacteristicSex',
                                      'QDM::PatientCharacteristicRace',
                                      'QDM::PatientCharacteristicEthnicity']
      # Find all data element types
      data_element_types = patient.qdmPatient.dataElements.map(&:_type)
      # Return if patient_characteristic_payer and 1 other data criteria is found, otherwise return an error message
      return unless (data_element_types - patient_characteristic_types).empty? || !(data_element_types.include? 'QDM::PatientCharacteristicPayer')

      msg =  'The Patient Data Section QDM (V6) - CMS shall contain at least one Patient Characteristic Payer template and at least one entry ' \
             'template that is other than the Patient Characteristic Payer template.'
      add_issue msg, :error, location: '/', validator_type: :xml_validation, file_name: options[:file_name]
    end

    def validate_criteria(checked_criteria)
      entered_values = checked_criteria.entered_values
      return unless entered_values&.count&.positive?

      values_found = entered_values.map do |entered_value|
        find_entered_value(entered_value, checked_criteria)
      end

      return unless values_found.compact.count == entered_values.count

      checked_criteria.criterion_verified = true
      checked_criteria.save
    end

    def find_entered_value(entered_value, checked_criteria)
      xpath_map = {
        'Patient Identification Number' => "//cda:recordTarget/cda:patientRole/cda:id[@extension='#{entered_value}' and ( @root!='2.16.840.1.113883.4.572' and @root!='2.16.840.1.113883.4.927')]",
        'MBI' => "//cda:recordTarget/cda:patientRole/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.4.927']",
        'HIC' => "//cda:recordTarget/cda:patientRole/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.4.572']",
        'CCN' => "//cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.4.336']",
        'CMS EHR Certification ID' => "//cda:participant/cda:associatedEntity/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.2074.1']",
        'NPI' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.4.6']",
        'TIN' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.4.2']",
        'CPCPLUS APM Entity Identifier' => "//cda:participant/cda:associatedEntity/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.249.5.1']",
        'PCF APM Entity Identifier' => "//cda:participant/cda:associatedEntity/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.249.5.3']",
        'MVP Code' => "//cda:participant[@typeCode='TRC']/cda:associatedEntity[@classCode='PROG']/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.249.5.6']",
        'SSP PI Reporting' => "//cda:participant[@typeCode='IND']/cda:associatedEntity[@classCode='PROG']/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.249.5.7']",
        'MIPS APM Entity Identifier' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.249.5.4']",
        'MCP APM Entity Identifier' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.249.5.4']",
        'MIPS Subgroup Identifier' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.249.5.5']",
        'Virtual Group Identifier' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@extension='#{entered_value}' and @root='2.16.840.1.113883.3.249.5.2']"
      }
      results = @file.xpath(xpath_map[checked_criteria[:criterion_key]])
      results.present? ? results : nil
    end
  end
end
