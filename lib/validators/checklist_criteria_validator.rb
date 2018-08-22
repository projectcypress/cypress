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

    def validate_criteria(checked_criteria)
      measure = Measure.find_by(_id: checked_criteria.measure_id)
      sdc = measure[:source_data_criteria].select { |key| key == checked_criteria.source_data_criteria }.values.first
      oids = HQMF::Util::HQMFTemplateHelper.get_all_hqmf_oids(sdc['definition'], sdc['status'])
      # demographics do not have an associated template
      if (['2.16.840.1.113883.3.560.1.406', '2.16.840.1.113883.3.560.1.403', '2.16.840.1.113883.3.560.1.402'] & oids).present?
        validate_demographics(oids, checked_criteria)
      else
        template = oids.map { |oid| QRDA::Util::QRDATemplateHelper.definition_for_template_id(oid, @qrda_version) }.compact.first['cda_template_id']
        # find all nodes that fulfill the data criteria, this is defined in checklist result extractor
        find_dc_node(template, checked_criteria, sdc)
      end
    end

    def validate_demographics(hqmf_oids, checked_criteria)
      xpath_map = {
        '2.16.840.1.113883.3.560.1.406' => "//cda:patient/cda:raceCode[@code='#{checked_criteria.code}']",
        '2.16.840.1.113883.3.560.1.403' => "//cda:patient/cda:ethnicGroupCode[@code='#{checked_criteria.code}']",
        '2.16.840.1.113883.3.560.1.402' => "//cda:patient/cda:administrativeGenderCode[@code='#{checked_criteria.code}']"
      }
      if hqmf_oids.map { |hqmf_oid| @file.xpath(xpath_map[hqmf_oid]).present? }.include? true
        checked_criteria.passed_qrda = true
        checked_criteria.save
      end
    end
  end
end
