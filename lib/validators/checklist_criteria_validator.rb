# require "cypress/qrda_file_validator"

module Validators
  class ChecklistCriteriaValidator < QrdaFileValidator
    include Validators::ChecklistResultExtractor
    include Validators::Validator
    include ::CqmValidators

    self.validator = :checklist

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
      @criteria_list.each do |criteria|
        next if criteria.passed_qrda

        validate_criteria(criteria)
      end
    end

    private

    def validate_criteria(checked_criteria)
      sdc = checked_criteria.source_data_criteria
      oid = sdc['hqmfOid']
      # oids = HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids(sdc['definition'], sdc['status'])
      # demographics do not have an associated template
      if sdc.qdmCategory == 'patient_characteristic'
        validate_demographics(sdc, checked_criteria)
      else
        template = QRDA::Util::QRDATemplateHelper.definition_for_template_id(oid, @qrda_version)['cda_template_id']
        # find all nodes that fulfill the data criteria, this is defined in checklist result extractor
        find_dc_node(template, checked_criteria, sdc)
      end
    end

    def validate_demographics(sdc, checked_criteria)
      xpath_map = {
        'QDM::PatientCharacteristicRace' => "//cda:patient/cda:raceCode[@code='#{checked_criteria.code}']",
        'QDM::PatientCharacteristicEthnicity' => "//cda:patient/cda:ethnicGroupCode[@code='#{checked_criteria.code}']",
        'QDM::PatientCharacteristicSex' => "//cda:patient/cda:administrativeGenderCode[@code='#{checked_criteria.code}']"
      }
      if @file.xpath(xpath_map[sdc._type]).present?
        checked_criteria.passed_qrda = true
        checked_criteria.save
      end
    end
  end
end
