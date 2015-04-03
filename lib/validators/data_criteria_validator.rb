module Validators
  class DataCriteriaValidator
    include Validators::Validator

    attr_accessor :measures
    attr_accessor :oids

    self.validator_type = :result_validation

    def initialize(measures)
      @measures = measures
      @oids = measures.collect{|m| m.oids}.flatten.uniq
    end

    def validate(doc, options ={})
        reported_oids = doc.xpath("//@sdtc:valueSet").collect{|att| att.value}.uniq

          # check for oids in the document not in the meausures
        disjoint_oids = reported_oids - HealthDataStandards::Validate::ValuesetValidator::HL7_QRDA_OIDS - oids
        if !disjoint_oids.empty?
    add_error(message: "File appears to contain data criteria outside that required by the measures. Valuesets in file not in measures tested #{disjoint_oids}'",
                                                   msg_type: :warning,
                                                   file_name: options[:file_name])
        end
    end
  end
end
