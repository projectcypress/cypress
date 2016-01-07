module Validators
  class CalculatingSmokingGunValidator < SmokingGunValidator
    include Validators::Validator
    def initialize(measures, records, test_id)
      if measures.length > 1
        # throw some kind of an error here because we only want to do this for
        # single measure testing
      end
      super
    end

    def compare_results(original, calculated, options)
      comp = true
      %w(IPP DENOM NUMER DENEX DENEXCEP MSRPOPL MSRPOPLEXCEP values).each do |pop|
        next unless original[pop] != calculated[pop]
        add_error("Calculated value for #{pop} does not match expected value  #{original[pop]} / #{calculated[pop]}",
                  file_name: options[:file_name])
        comp = false
      end
      comp
    end

    def validate_calculated_results(doc, options)
      te = options['test_execution']
      @mre = QME::MapReduce::Executor.new(@measure.id, @measure.sub_id, 'test_id' => te.id, 'bundle_id' => @product_test.bundle.id)
      record = HealthDataStandards::Import::BulkRecordImporter.import(doc)
      record.test_id = te.id
      unless record.medical_record_number
        record.medical_record_number = rand(1_000_000_000_000_000)
      end
      record.save
      results = @mre.get_patient_result(record.medical_record_number)

      doc_name = build_doc_name(doc)
      mrn = @names[doc_name]
      return false unless mrn
      original_results = QME::PatientCahce.where('value.medical_record_number' => mrn,
                                                 'value.test_id' => @product_test.id,
                                                 'value.measure_id' => @measure.hqmf_id,
                                                 'value.sub_id' => @measure.sub_id).first
      compare_results(original_results, results, options)
    end

    def validate(doc, options)
      valid = validate_calculated_results(doc, options)
      if !valid
        doc_name = build_doc_name(doc)
        mrn = @names[doc_name]
        @found_names << doc_name if mrn
        validate_name(doc_name, options)
      else
        super
      end
    end
  end
end
