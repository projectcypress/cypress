# require "cypress/qrda_file_validator"

module Validators
  class ProgramCriteriaValidator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators

    self.validator = :checklist

    def initialize(program_test)
      @criteria_list = program_test.program_criteria
      @criteria_list.each do |criteria|
        # set passing flag to false during each validation
        criteria.criterium_verified = false
        criteria.save!
      end
    end

    # Validates a QRDA Cat I file.  This routine will validate the file against the checklist criteria
    def validate(file, options = {})
      @file = file
      @criteria_list.each do |criteria|
        # if a criteria has already passed, no need to check again
        next if criteria.criterium_verified

        next unless validate_criteria(criteria)

        criteria.criterium_verified = true
        criteria.file_name = options[:file_name]
        criteria.save
      end
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
      results = @file.xpath(xpath_map[checked_criteria[:criterium_key]])
      if results.present?
        checked_criteria.criterium_verified = true
        checked_criteria.save
      end
    end
  end
end
