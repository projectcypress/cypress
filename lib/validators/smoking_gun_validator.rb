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
            template_smg =map_to_templates(patient_sgd)
            template_smg.each_pair do |template,entries|
              count = doc.xpath("count(//cda:templateId[@root='#{template}'])")
              entry_count = entries.collect{|e| e[:rationale].kind_of?(Hash) ?  e[:rationale]["results"]  : [true] }.compact.flatten.uniq.count
              unless count >= 1 # entry_count - relaxing sgd constriants
                 errors << ExecutionError.new(message: "Expected to find #{entry_count} entries with templateId #{template}", msg_type: :error, validator_type: :result_validation, file_name: options[:file_name])
              end 
            end
            # data_elements = map_to_data_elements(patient_sgd)
            # data_elements.each_pair do |de_id,dc_matches|
            #   found = false
            #   dc_matches.each do |dc_match|
            #     nodes = doc.xpath("//cda:templateId[@root='#{dc_match[:template]}']/..//*[@sdtc:valueSet='#{dc_match[:oid]}']")
            #     if nodes.length != 0 
            #       found = true
            #     end
            #   end

            #   if !found
            #    template_mapping =  dc_matches.collect do |dc_match|
            #       "[Template: #{dc_match[:template]} -> Valueset: #{dc_match[:oid]}]"
            #     end
            #     errors << ExecutionError.new(message: "Cannot find one of the expected mappings #{template_mapping}",msg_type: :error, validator_type: :result_validation, file_name: options[:file_name])
            #   end

            # end
	      	end
	      end
	    else
	    	errors << ExecutionError.new(message: "Automated smoking gun data checking is not compatible with bundle #{@bundle.version} please refer to checklists ",msg_type: :warning, validator_type: :result_validation, file_name: options[:file_name])  		
	    end
      errors
		end

    def map_to_templates(rationale)
      mapping = {}
      rationale.each do |dc|
        template = dc[:template]
        if template != "N/A"
          entries = mapping[template] ||= []
          entries << dc
        end
      end
      mapping

    end

    def map_to_data_elements(rationale)
      mapping = {}
      rationale.each do |dc|
        if dc[:template] != "N/A"
          temp = {template: dc[:template], oid: dc[:oid]}
          rati = dc[:rationale]
          if  rati &&  rati.kind_of?(Hash) && rati["results"]
             rati["results"].each do |res|
              mapping[res['id']] ||= []
              mapping[res['id']] << temp 
            end
          end
        end
      end
      mapping
    end

	end
end
