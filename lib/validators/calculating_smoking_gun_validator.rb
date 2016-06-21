module Validators
  class CalculatingSmokingGunValidator < SmokingGunValidator
    include Validators::Validator
    def initialize(measures, records, test_id, options = {})
      @measures = measures
      super
    end

    def compare_results(original, calculated, options, previously_passed)
      if original.nil? && calculated.nil?
        true && previously_passed
      else
        comp = true
        %w(IPP DENOM NUMER DENEX DENEXCEP MSRPOPL MSRPOPLEXCEP values).each do |pop|
          original_value, calculated_value, pop = extract_calcuated_and_original_results(original, calculated, pop)
          next unless original_value != calculated_value
          pop_statment = options[:population_ids][pop]
          pop_statment << " Stratification #{options[:population_ids]['STRAT']}" if options[:population_ids]['STRAT']
          add_error("Calculated value (#{calculated_value}) for #{pop} (#{pop_statment}) does not match expected value (#{original_value})",
                    file_name: options[:file_name])
          comp = false
        end
        previously_passed && comp
      end
    end

    def extract_calcuated_and_original_results(original, calculated, pop)
      # set original value to 0 if it wasn't calculated
      original_value = original.nil? || original.value[pop].nil? ? 0.0 : original.value[pop]
      # set calculated value to 0 if there is no calculation for the measure or population
      calculated_value = calculated.nil? || calculated[pop].nil? ? 0.0 : calculated[pop]
      if pop == 'values'
        pop = 'OBSERV'
        # the orginal and calculated values should be an array make empty if it doesn't exist
        original_value = [] if original.nil? || !original.is_a?(Array)
        calculated_value = [] if calculated.nil? || !calculated.is_a?(Array)
      end
      [original_value, calculated_value, pop]
    end

    def parse_and_save_record(doc, te, options)
      record = GoCDATools::Import::GoImporter.instance.parse_with_ffi(doc)
      record.test_id = te.id
      record.medical_record_number = rand(1_000_000_000_000_000)
      record.save
      record
    rescue
      add_error('File failed import', file_name: options[:file_name])
      nil
    end

    def get_mrn(doc)
      doc_name = build_doc_name(doc)
      mrn = @names[doc_name]
      return nil unless mrn
      mrn
    end

    def validate_calculated_results(doc, options)
      te = options['test_execution']

      mrn = get_mrn(doc)
      return false unless mrn

      passed = true
      record = parse_and_save_record(doc, te, options)
      return false unless record
      @measures.each do |measure|
        ex_opts = { 'test_id' => te.id, 'bundle_id' => @bundle.id,  'effective_date' => te.task.effective_date,
                    'enable_logging' => true, 'enable_rationale' => true, 'oid_dictionary' => generate_oid_dictionary(measure, @bundle.id) }
        @mre = QME::MapReduce::Executor.new(measure.hqmf_id, measure.sub_id, ex_opts)
        results = @mre.get_patient_result(record.medical_record_number)
        original_results = QME::PatientCache.where('value.medical_record_id' => mrn, 'value.test_id' => @test_id,
                                                   'value.measure_id' => measure.hqmf_id, 'value.sub_id' => measure.sub_id).first
        options[:population_ids] = measure.population_ids
        passed = compare_results(original_results, results, options, passed)
      end
      record.destroy
      passed
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
      @can_continue = true
      valid = validate_calculated_results(doc, options)
      if valid
        doc_name = build_doc_name(doc)
        mrn = @names[doc_name]
        @found_names << doc_name if mrn
        # we still need to validate that the returned record is one of the test records
        # and that it was expected to be returned (ie, in the IPP)
        validate_name(doc_name, options) && validate_expected_results(doc_name, mrn, options)
      else
        super
      end
    end
  end
end
