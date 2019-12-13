# require "cypress/qrda_file_validator"

module Validators
  class ProgramCriteriaValidator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators

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
      calculate_patient(options) if options.task.product_test.reporting_program_type == 'eh'
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

    def calculate_patient(options)
      patient = QRDA::Cat1::PatientImporter.instance.parse_cat1(@file)
      patient.update(_type: CQM::TestExecutionPatient, correlation_id: options.test_execution.id.to_s)
      patient.save!
      patient_has_pcp_and_other_element(patient, options)
      post_processsor_check(patient, options)
      calc_job = Cypress::CqmExecutionCalc.new([patient.qdmPatient],
                                               options.task.product_test.measures,
                                               options.test_execution.id.to_s,
                                               'effectiveDateEnd': Time.at(options.task.effective_date).in_time_zone.to_formatted_s(:number),
                                               'effectiveDate': Time.at(options.task.measure_period_start).in_time_zone.to_formatted_s(:number),
                                               'file_name': options[:file_name])
      calc_job.execute(true)
    end

    def post_processsor_check(patient, options)
      # check for single code negation errors
      errors = Cypress::QRDAPostProcessor.issues_for_negated_single_codes(patient, options.task.bundle, options.task.product_test.measures)
      errors.each { |e| add_error e, file_name: options[:file_name] }
      Cypress::QRDAPostProcessor.replace_negated_codes(patient, options.task.bundle)
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
      xpath_map = {
        'Patient Identification Number' => "//cda:recordTarget/cda:patientRole/cda:id[@extension='#{checked_criteria.entered_value}' and ( @root!='2.16.840.1.113883.4.572' and @root!='2.16.840.1.113883.4.927')]",
        'MBI' => "//cda:recordTarget/cda:patientRole/cda:id[@extension='#{checked_criteria.entered_value}' and @root='2.16.840.1.113883.4.927']",
        'HIC' => "//cda:recordTarget/cda:patientRole/cda:id[@extension='#{checked_criteria.entered_value}' and @root='2.16.840.1.113883.4.572']",
        'CCN' => "//cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:id[@extension='#{checked_criteria.entered_value}' and @root='2.16.840.1.113883.4.336']",
        'CMS EHR Certification ID' => "//cda:participant/cda:associatedEntity/cda:id[@extension='#{checked_criteria.entered_value}' and @root='2.16.840.1.113883.3.2074.1']",
        'NPI' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id[@extension='#{checked_criteria.entered_value}' and @root='2.16.840.1.113883.4.6']",
        'TIN' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@extension='#{checked_criteria.entered_value}' and @root='2.16.840.1.113883.4.2']",
        'CPCPLUS APM Entity Identifier' => "//cda:participant/cda:associatedEntity/cda:id[@extension='#{checked_criteria.entered_value}' and @root='2.16.840.1.113883.3.249.5.1']",
        'Virtual Group Identifier' => "//cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@extension='#{checked_criteria.entered_value}' and @root='2.16.840.1.113883.3.249.5.2']"
      }
      results = @file.xpath(xpath_map[checked_criteria[:criterion_key]])
      if results.present?
        checked_criteria.criterion_verified = true
        checked_criteria.save
      end
    end
  end
end
