# frozen_string_literal: true

module Validators
  class QrdaFileValidator
    include Validators::Validator

    self.validator_type = :result_validation

    def get_document(doc)
      doc = Nokogiri::XML(doc) if doc.is_a?(String)
      raise ArgumentError, 'Argument was not an XML document' unless doc.root

      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
      doc
    end

    def translate(id)
      %{translate(#{id}, "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ")}
    end
  end
end
