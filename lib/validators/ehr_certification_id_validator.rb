# frozen_string_literal: true

# For MIPS submissions, CMS EHR Certification ID is only required if Promoting Interoperability performance category
# (Promoting Interoperability Section (V2) identifier: urn:hl7ii:2.16.840.1.113883.10.20.27.2.5:2017-06-01)
# is present in a QRDA III document.
module Validators
  class EhrCertificationIdValidator < QrdaFileValidator
    include Validators::Validator

    def validate(file, options = {})
      @document = get_document(file)
      # Look for Promoting Interoperability Section (V2) identifier
      has_pi = @document.at_xpath("//cda:component/cda:section[cda:templateId/@root = '2.16.840.1.113883.10.20.27.2.5']")
      # If Promoting Interoperability Section is not there, return
      return unless has_pi

      # Otherwise, look for the certification ID
      cert_id = @document.at_xpath("//cda:participant/cda:associatedEntity[cda:id/@root = '2.16.840.1.113883.3.2074.1']")
      return if cert_id

      # If certification isn't in document, return an error
      msg = 'CMS EHR Certification ID is required if Promoting Interoperability performance category (Promoting Interoperability Section (V2) ' \
            'identifier: urn:hl7ii:2.16.840.1.113883.10.20.27.2.5:2017-06-01) is present in a QRDA III document. If CMS EHR Certification ID ' \
            'is not supplied, the score for the PI performance category will be 0.'
      add_error(msg, file_name: options[:file_name])
    end
  end
end
