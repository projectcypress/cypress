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
			@bundle =  ProductTest.find(@test_id).bundle
			@expected_records = []
			@sgd = {}
			@found_names = []
			
			if @bundle.smoking_gun_capable
				@measures.each do |mes|
					@sgd[mes.hqmf_id] = mes.smoking_gun_data({"value.test_id" => test_id})
					@expected_records.concat @sgd[mes.hqmf_id].keys
				end
				@expected_records = @expected_records.flatten.uniq
			end

			@names = Hash[*self.records.collect{|r| ["#{r.first.strip} #{r.last.strip}".upcase,r.medical_record_number]}.flatten]
		end

		def expected_records
			@expected_records
		end

		def found_names
			@found_names
		end

		def not_found_names
			@names.keys - @found_names
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
      @found_names << doc_name if mrn

      unless @names[doc_name]
         errors << ExecutionError.new(message: "Patient name '#{doc_name}' declared in file not found in test records'", msg_type: :error, validator_type: :result_validation, file_name: options[:file_name])
      	 #cannot go any further here so call it quits and return
      	 return errors
      end

      
      if @bundle.smoking_gun_capable

	      if @expected_records.index(mrn).nil?
						errors << ExecutionError.new(message: "Patient '#{doc_name}' not expected to be returned.'", msg_type: :error, validator_type: :result_validation, file_name: options[:file_name])
	      	 #cannot go any further here so call it quits and return
	      end

	      @sgd.each_pair do |hqmf_id, patient_data|
	      	patient_sgd = patient_data[mrn]
	      	if patient_sgd
	      		patient_sgd.each do |dc|
	      			if dc[:template] != "N/A"
		      			nodes = doc.xpath("//cda:templateId[@root='#{dc[:template]}']/../*[@sdtc:valueSet='#{dc[:oid]}']")
		      			if nodes.length == 0 
		      				errors << ExecutionError.new(message: "Cannot find expected entry with templateId = #{dc[:template]} with valueset #{dc[:oid]}",msg_type: :error, validator_type: :result_validation, file_name: options[:file_name])
		      			end
		      		end

	      		end
	      	end
	      end
	    else
	    	errors << ExecutionError.new(message: "Automated smoking gun data checking is not compatible with bundle #{@bundle.version} please refer to checklists ",msg_type: :warning, validator_type: :result_validation, file_name: options[:file_name])  		
	    end
      errors
		end
	end
end
