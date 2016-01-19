module Validators
  class CalculatingSmokingGunValidator < SmokingGunValidator
    include Validators::Validator
    def initialize(measures, records, test_id)
      if measures.length > 1
        # throw some kind of an error here because we only want to do this for
        # single measure testing
      end
      super
      @measure = measures.first
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
      ex_opts = { 'test_id' => te.id, 'bundle_id' => @bundle.id,  'effective_date' => te.task.effective_date,
                  'enable_logging' => true, 'enable_rationale' => true,
                  'oid_dictionary' => generate_oid_dictionary(@measure, @bundle.id) }
      @mre = QME::MapReduce::Executor.new(@measure.hqmf_id, @measure.sub_id, ex_opts)
      record = HealthDataStandards::Import::Cat1::PatientImporter.instance.parse_cat1(doc)

      record.test_id = te.id
      record.medical_record_number = rand(1_000_000_000_000_000)
      record.save

      results = @mre.get_patient_result(record.medical_record_number)

      doc_name = build_doc_name(doc)
      mrn = @names[doc_name]
      return false unless mrn
      original_results = QME::PatientCache.where('value.medical_record_id' => mrn,
                                                 'value.test_id' => @test_id,
                                                 'value.measure_id' => @measure.hqmf_id,
                                                 'value.sub_id' => @measure.sub_id).first
      return true if original_results.nil? && results.nil?
      compare_results(original_results.value, results, options)
    end

    def generate_oid_dictionary(measure, bundle_id)
      valuesets = HealthDataStandards::CQM::Bundle.find(bundle_id).value_sets.in(oid: measure.oids)
      js = {}
      valuesets.each do |vs|
        js[vs.oid] = cached_value(vs)
      end
      js.to_json
    end

    def cached_value(vs)
      @loaded_valuesets ||= {}
      return @loaded_valuesets[vs.oid] if @loaded_valuesets[vs.oid]
      js = {}
      vs.concepts.each do |con|
        name = con.code_system_name
        js[name] ||= []
        js[name] << con.code.downcase unless js[name].index(con.code.downcase)
      end
      @loaded_valuesets[vs.oid] = js
      js
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
