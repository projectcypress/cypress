module Validators
  class SmokingGunValidator
    include Validators::Validator

    attr_accessor :measures
    attr_accessor :test_id
    attr_accessor :sgd
    attr_accessor :records
    attr_accessor :names
    attr_accessor :expected_records
    attr_reader :found_names
    self.validator_type = :result_validation

    def initialize(measures, records, test_id)
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
    end

    def init_data
      @sgd = {}
      @expected_records = []
      if @bundle.smoking_gun_capable
        @measures.each do |mes|
          @sgd[mes.hqmf_id] = mes.smoking_gun_data('value.test_id' => @test_id)
          @expected_records.concat @sgd[mes.hqmf_id].keys
        end
        @expected_records = @expected_records.flatten.uniq
      else
        @expected_records = []
      end
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
      return true if @names[doc_name]
      add_error("Patient name '#{doc_name}' declared in file not found in test records'",
                file_name: options[:file_name])
      false
    end

    def validate_expected_results(doc_name, mrn, options)
      return true if @expected_records.index(mrn)
      add_error("Patient '#{doc_name}' not expected to be returned.'",
                file_name: options[:file_name])
      # cannot go any further here so call it quits and return
      nil
    end

    def validate_smg_data(doc, doc_name, mrn, options)
      return unless validate_expected_results(doc_name, mrn, options)
      @sgd.each_pair do |_hqmf_id, patient_data|
        patient_sgd = patient_data[mrn]
        next unless patient_sgd
        patient_sgd.each do |dc|
          next if dc[:template] == 'N/A'
          nodes = doc.xpath("//cda:templateId[@root='#{dc[:template]}']/..//*[@sdtc:valueSet='#{dc[:oid]}']")
          add_error("Cannot find expected entry with templateId = #{dc[:template]} with valueset #{dc[:oid]}",
                    file_name: options[:file_name]) if nodes.length == 0
        end
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
      doc = build_document(document)
      doc_name = build_doc_name(doc)
      mrn = @names[doc_name]
      @found_names << doc_name if mrn
      return unless validate_name(doc_name, options)

      if @bundle.smoking_gun_capable
        validate_smg_data(doc, doc_name, mrn, options)
      else
        add_warning(%W(Automated smoking gun data checking is not compatible
                       with bundle #{@bundle.version}, please refer to checklists),
                    file_name: options[:file_name])
      end
    end
  end
end
