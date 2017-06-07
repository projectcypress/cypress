# require "cypress/qrda_file_validator"

module Validators
  class ChecklistCriteriaValidator < QrdaFileValidator
    include Validators::ChecklistResultExtractor
    include Validators::Validator
    include HealthDataStandards::Validate

    self.validator = :checklist

    def initialize(checklist_test)
      @criteria_list = checklist_test.checked_criteria
      @criteria_list.each do |criteria|
        # set passing flag to false during each validation
        criteria.passed_qrda = false
        criteria.save!
      end
    end

    # Validates a QRDA Cat I file.  This routine will validate the file against the checklist criteria
    def validate(file, _options = {})
      @file = file
      @criteria_list.each do |criteria|
        next if criteria.passed_qrda
        validate_criteria(criteria)
      end
    end

    def validate_criteria(checked_criteria)
      measure = Measure.find_by(_id: checked_criteria.measure_id)
      sdc = measure.hqmf_document[:data_criteria].select { |key| key == checked_criteria.source_data_criteria }.values.first
      hqmf_oid = HQMF::DataCriteria.template_id_for_definition(sdc['definition'], sdc['status'], sdc['negation'])
      hqmf_oid ||= HQMF::DataCriteria.template_id_for_definition(sdc['definition'], sdc['status'], sdc['negation'], 'r2')
      # demographics do not have an associated template
      if ['2.16.840.1.113883.3.560.1.406', '2.16.840.1.113883.3.560.1.403', '2.16.840.1.113883.3.560.1.402'].include?(hqmf_oid)
        validate_demographics(hqmf_oid, checked_criteria)
      else
        template = HealthDataStandards::Export::QRDA::EntryTemplateResolver.qrda_oid_for_hqmf_oid(hqmf_oid, 'r3_1').split('_').first
        # find valuesets relevant to the data criteria
        valuesets = checked_criteria.get_all_valuesets_for_dc(checked_criteria.measure_id)
        # find all nodes that fulfill the data criteria, this is defined in checklist result extractor
        find_dc_node(template, valuesets, checked_criteria, sdc)
      end
    end

    def validate_demographics(hqmf_oid, checked_criteria)
      xpath_map = {
        '2.16.840.1.113883.3.560.1.406' => "//cda:patient/cda:raceCode[@code='#{checked_criteria.code}']",
        '2.16.840.1.113883.3.560.1.403' => "//cda:patient/cda:ethnicGroupCode[@code='#{checked_criteria.code}']",
        '2.16.840.1.113883.3.560.1.402' => "//cda:patient/cda:administrativeGenderCode[@code='#{checked_criteria.code}']"
      }
      results = @file.xpath(xpath_map[hqmf_oid])
      unless results.blank?
        checked_criteria.passed_qrda = true
        checked_criteria.save
      end
    end
  end
end
