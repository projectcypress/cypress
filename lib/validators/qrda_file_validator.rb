require 'quality-measure-engine'
module Validators
  class QrdaFileValidator

    require 'cypress/qrda_file_constants'

    def get_document(doc)
      doc = (doc.kind_of? String )? Nokogiri::XML(doc) : doc
      raise ArgumentError, 'Argument was not an XML document' unless doc.root
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
      doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")
      doc
    end

    def translate(id)
      %{translate(#{id}, "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ")}
    end
  end
end
