module Validators
  class SmokingGunValidator
    include Validators::Validator

    attr_accessor :measures, :test_id, :sgd, :records, :names, :expected_records, :can_continue
    attr_reader :found_names

    self.validator_type = :result_validation
    self.validator = :smoking_gun

    def initialize(measures, records, test_id, options = {})
      @measures = measures
      @records = records
      @test_id = test_id
      @bundle =  ProductTest.find(@test_id).bundle
      @found_names = []
      init_data
      @names = Hash[*records.collect do |r|
        ["#{r.first.strip} #{r.last.strip}".upcase,
         r.medical_record_number]
      end.flatten]
      @can_continue = true
      @options = options
    end

    def init_data
      @sgd = {}
      @expected_records = []
      @measures.each do |mes|
        @sgd[mes.hqmf_id] = mes.smoking_gun_data('value.test_id' => @test_id)
        @expected_records.concat @sgd[mes.hqmf_id].keys
      end
      @expected_records = @expected_records.flatten.uniq
    end

    def not_found_names
      expected_names = []
      @expected_records.each do |expected_record|
        expected_names << @names.key(expected_record) if @names.value?(expected_record)
      end
      expected_names - @found_names
    end

    def errors
      sg_errors = super.dup
      unless not_found_names.empty?
        msg = "Records for patients #{not_found_names.join(', ')} not found in archive as expected"
        sg_errors << ExecutionError.new(:message => msg, :msg_type => :error, :validator_type => :result_validation)
      end

      sg_errors
    end

    def validate_name(doc_name, options)
      return true if @names[doc_name] ||
                     !options['task'].augmented_records.index { |r| doc_name == "#{r[:first][1].strip} #{r[:last][1].strip}".upcase }.nil?
      @can_continue = false
      return false if @options[:suppress_errors]
      add_error("Patient name '#{doc_name}' declared in file not found in test records",
                file_name: options[:file_name])
      false
    end

    def validate_expected_results(doc_name, mrn, options)
      return true if @expected_records.index(mrn)
      @can_continue = false
      return nil if @options[:suppress_errors]
      add_error("Patient '#{doc_name}' not expected to be returned.",
                file_name: options[:file_name])
      # cannot go any further here so call it quits and return
      nil
    end

    def validate_smg_data(doc, doc_name, mrn, options)
      return unless validate_expected_results(doc_name, mrn, options)
      return if @options[:validate_inclusion_only]
      @sgd.each_pair do |_hqmf_id, patient_data|
        patient_sgd = patient_data[mrn]
        next unless patient_sgd
        patient_sgd.each do |dc|
          next if dc[:template] == 'N/A'
          add_error("Cannot find expected entry with templateId = #{dc[:template]} with valueset #{dc[:oid]}",
                    file_name: options[:file_name]) if find_dc_nodes(doc, dc).empty?
        end
      end
    end

    def find_dc_nodes(doc, data_criteria)
      if data_criteria[:template] == '2.16.840.1.113883.10.20.24.3.9' && data_criteria[:rationale][:results][0][:json][:negationInd]
        doc.xpath("//cda:act[cda:code/@code = 'SPLY']/..//*[@sdtc:valueSet='#{data_criteria[:oid]}']")
      else
        doc.xpath("//cda:templateId[@root='#{data_criteria[:template]}']/..//*[@sdtc:valueSet='#{data_criteria[:oid]}']")
      end
    end

    def build_doc_name(doc)
      # find the mrn for the document
      first = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given/text()')
      last = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family/text()')
      "#{first.to_s.strip} #{last.to_s.strip}".upcase
    end

    def build_document(document)
      doc = (document.is_a? Nokogiri::XML::Document) ? document : Nokogiri::XML(document.to_s)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
      doc
    end

    def validate(document, options = {})
      @can_continue = true
      doc = build_document(document)
      doc_name = build_doc_name(doc)
      aug_rec = options['task'].augmented_records.detect { |r| doc_name == "#{r[:first][1].strip} #{r[:last][1].strip}".upcase }
      mrn = @names[doc_name] || (aug_rec ? aug_rec.medical_record_number : nil)
      @found_names << ((@names[doc_name] ? doc_name : nil) ||
                       "#{aug_rec[:first][0].strip} #{aug_rec[:last][0].strip}".upcase) if mrn
      return unless validate_name(doc_name, options)

      validate_smg_data(doc, doc_name, mrn, options)
    end
  end
end
