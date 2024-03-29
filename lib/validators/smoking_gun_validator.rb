# frozen_string_literal: true

module Validators
  class SmokingGunValidator
    include Validators::Validator
    include QrdaHelper

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
        [to_doc_name(r.givenNames.join(' '), r.familyName),
         r.id]
      end.flatten]
      @can_continue = true
      @options = options
    end

    def init_data
      @expected_records = []
      @measures.each do |mes|
        @expected_records << CQM::IndividualResult.where('measure_id' => mes.id, 'IPP' => { '$gt' => 0 },
                                                         correlation_id: @test_id.to_s).distinct(:patient)
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
        sg_errors << ExecutionError.new(message: msg, msg_type: :error, validator_type: :result_validation)
      end

      sg_errors
    end

    def to_doc_name(first, last)
      "#{first.strip} #{last.strip}".upcase
    end

    # Returns the medical record number the given document if it is found. Otherwise, returns
    def get_record_identifiers(doc, options)
      doc_name = build_doc_name(doc)
      aug_rec = options['task'].augmented_patients.detect { |r| doc_name == to_doc_name(r[:first][1], r[:last][1]) }
      mrn = @names[doc_name] || aug_rec&.original_patient_id
      [mrn || nil, doc_name, aug_rec, parse_telecoms(doc)]
    end

    def validate_name(doc_name, options)
      return true if @names[doc_name] ||
                     !options['task'].augmented_patients.index { |r| doc_name == to_doc_name(r[:first][1], r[:last][1]) }.nil?

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

    def build_doc_name(doc)
      # find the mrn for the document
      first = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given')
      last = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family')
      "#{first.text.strip} #{last.text.strip}".upcase
    end

    def build_document(document)
      doc = document.is_a?(Nokogiri::XML::Document) ? document : Nokogiri::XML(document.to_s)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
      doc
    end

    def validate(document, options = {})
      @can_continue = true
      doc = build_document(document)
      mrn, doc_name, aug_rec = get_record_identifiers(doc, options)
      @found_names << ((@names[doc_name] ? doc_name : nil) || to_doc_name(aug_rec[:first][0], aug_rec[:last][0])) if mrn
      return unless validate_name(doc_name, options)

      validate_expected_results(doc_name, mrn, options)
    end
  end
end
