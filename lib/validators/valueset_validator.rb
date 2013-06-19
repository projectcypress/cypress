module Validators
	class ValuesetValidator
		 attr_accessor :bundle
		 def initialize(bundle)
		 	@bundle = bundle
		 end

			def validate(document,data={})

				doc = (document.kind_of? Nokogiri::XML::Document)? document : Nokogiri::XML(document.to_s)
				doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
				doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")
				errors = []
				# get all of the valueset items for the document
				sdtc_values = doc.xpath("//*[@sdtc:valueSet]")

				sdtc_values.each do |node|
					oid = node.at_xpath("@sdtc:valueSet")
					code = node.at_xpath("@code")
					code_system = node.at_xpath("@codeSystem")
					null_flavor = node.at_xpath("@nullFlavor")
					vs = bundle.value_sets.where({"oid" => oid}).first
					
					
					if vs.nil?
						errors << Cypress::ValidationError.new(
			                :message => "The valueset #{oid} declared in the document cannot be found",
			                :validator => "Valueset Validator",
			                :validator_type => :xml_validation,
			                :msg_type=>(data[:msg_type] || :error),
			                :file_name => data[:file_name],
			                location: node.path
			              )
					elsif vs.concepts.where({"code" => code, "code_system"=>code_system}).count() == 0
						if null_flavor
							errors <<  Cypress::ValidationError.new(
				                :message => "Null flavor declared for valueset entry #{oid}",
				                :validator => "Valueset Validator",
				                :validator_type => :xml_validation,
				                :msg_type=>:warning,
				                :file_name => data[:file_name],
				                location: node.path
				              )
						else	
							errors <<  Cypress::ValidationError.new(
				                :message => "The code #{code} in codeSystem #{code_system} cannot be found in the declared valueset #{oid} ",
				                :validator => "Valueset Validator",
				                :validator_type => :xml_validation,
				                :msg_type=>(data[:msg_type] || :error),
				                :file_name => data[:file_name],
				                location: node.path
				              )
						end
					end

				end
				errors
		 end
	end
end