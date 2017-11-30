module Validators
  class ProviderTypeValidator < QrdaFileValidator
    include Validators::Validator

    self.validator = :provider_type

    PROVIDER_TYPE_SELECTOR = '/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:code/@code'.freeze

    def initialize; end

    def validate(file, options = {})
      @document = get_document(file)
      @options = options
      first, last = extract_first_and_last_names
      record = @options['task'].records.where(first: first, last: last).first
      if record
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

    def extract_first_and_last_names
      # find the mrn for the document, borrowed from smoking gun validator
      first = @document.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given/text()')
      last = @document.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family/text()')
      doc_name = "#{first.to_s.strip} #{last.to_s.strip}".upcase

      aug_index = @options['task'].augmented_records.index { |r| doc_name == "#{r[:first][1].strip} #{r[:last][1].strip}".upcase }
      if aug_index
        first = @options['task'].augmented_records[aug_index]['first'][0]
        last = @options['task'].augmented_records[aug_index]['last'][0]
      end
      [first, last]
    end
  end
end
