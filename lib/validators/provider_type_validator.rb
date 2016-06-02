module Validators
  class ProviderTypeValidator < QrdaFileValidator
    include Validators::Validator

    self.validator = :provider_type

    PROVIDER_TYPE_SELECTOR = '/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:code/@code'.freeze

    def initialize
    end

    def validate(file, options = {})
      @document = get_document(file)
      @options = options

      # find the mrn for the document, borrowed from smoking gun validator
      first = @document.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given/text()')
      last = @document.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family/text()')

      record = options['task'].records.where(first: first, last: last).first

      expected_provider_types = record.provider_performances.collect { |pp| pp.provider.specialty }

      found_provider_types = @document.xpath(PROVIDER_TYPE_SELECTOR).map(&:value)

      expected_provider_types.sort
      found_provider_types.sort

      if expected_provider_types != found_provider_types
        add_error("Provider specialties (#{found_provider_types.join(', ')}) do not match expected value (#{expected_provider_types.join(', ')})",
                  file_name: options[:file_name])
      end
    end
  end
end
