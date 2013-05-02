module Validators
	class ValuesetValidator
		 def initialize(bundle)

		 end

			def validate(document,data={})
				doc = (document.kind_of? Nokogiri::XML::Document)? document : Nokogiri::XML(document.to_s)
				doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
				doc.root.add_namespace_definition("stdc", "urn:hl7-org:stdc")
				errors = []
				# get all of the valueset items for the document
				sdtc_values = doc.xpath("//[count(@stdc:valueset) = 1]")
				sdtc_values.each do |node|
					oid = node.at_xpath("@stdc:valueset")
					code = node.at_xpath("@code")
					code_system = node.at_xpath("@codeSystem")
					vs = bundle.valuesets.where({"oid" => oid}).first
					if vs.nil?
						errors << Cypress::ValidationError.new(
                :message => "The valueset #{oid} declared in the document cannot be found",
                :validator => "",
                :validator_type => :xml_validation,
                :msg_type=>(data[:msg_type] || :error),
                :file_name => data[:file_name],
                location: node.path
              )
					elsif vs.concepts.where({"code" => code, "codeSystem"=>code_system}).count() > 0
						errors <<  Cypress::ValidationError.new(
                :message => "The code #{code} in codeSystem #{code_system} cannot be found in the declared valueset #{oid} ",
                :validator => "",
                :validator_type => :xml_validation,
                :msg_type=>(data[:msg_type] || :error),
                :file_name => data[:file_name],
                location: node.path
              )
					end

				end
		 end
	end
end