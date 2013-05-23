module Validators
	class SmokingGunValidator
		attr_accessor :measures
		attr_accessor :test_id
		attr_accessor :sgd
		attr_accessor :records
		attr_accessor :names

		def initialize(measures, records, test_id)
			@measures = measures
			@records = records
			@test_id = test_id

			@sgd = {}
			@measures.each do |mes|
				@sgd[mes.hqmf_id] = mes.smoking_gun_data({"value.test_id" => test_id.to_s})
			end

			@names = Hash[*self.records.collect{|r| ["#{r.first.strip} #{r.last.strip}".upcase,r.medical_record_number]}.flatten]
		end

		def validate(document, options={})
			doc = (document.kind_of? Nokogiri::XML::Document)? document : Nokogiri::XML(document.to_s)
			doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
			doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")
			errors = []
			
			# find the mrn for the document
			first = doc.at_xpath("/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given/text()")
      last = doc.at_xpath("/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family/text()")
			doc_name = "#{first.to_s.strip} #{last.to_s.strip}".upcase
      mrn = @names[doc_name]

      unless @names[doc_name]
         errors << ExecutionError.new(message: "Pateint name '#{doc_name}' declared in file not found in test records'", msg_type: :error, validator_type: :result_validation, file_name: options[:file_name])
      	 #cannot go any further here so call it quits and return
      	 return errors
      end

      @sgd.each_pair do |hqmf_id, patient_data|
      	patient_sgd = patient_data[mrn]
      	if patient_sgd
      		patient_sgd.each do |dc|
      			nodes = doc.xpath("//cda:templateId[@root='#{dc[:template_id]}']/../*[@sdtc:valueSet='dc[:oid]']")
      			if node.length == 0
      				errors << ExecutionError.new(message: "Cannot find expected entry with templateId = #{cd[:template_id]} with valueset #{cd[:oid]}")
      			end
      		end
      	end
      end
      errors
		end
	end
end
