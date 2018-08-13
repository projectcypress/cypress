module Validators
  class CalculatingSmokingGunValidator < SmokingGunValidator
    include Validators::Validator
    def initialize(measures, records, test_id, options = {})
      @measures = measures
      @hqmf_map = HealthDataStandards::Export::QRDA::EntryTemplateResolver.hqmf_qrda_oid_map
      @hds_record_converter = CQM::Converter::HDSRecord.new
      super
    end

    def compare_results(original, calculated, options, previously_passed)
      if original.nil? && calculated.nil?
        true && previously_passed
      else
        comp = true
        %w[IPP DENOM NUMER DENEX DENEXCEP MSRPOPL MSRPOPLEXCEP values].each do |pop|
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
      original_value = original.nil? || original[pop].nil? ? 0.0 : original[pop]
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

    def description_for_hqmf_oid(entry_oid)
      hqmf_qrda_tuple = @hqmf_map.find { |map_tuple| map_tuple['hqmf_oid'] == entry_oid }
      "#{hqmf_qrda_tuple['hqmf_name']}:"
    end

    def parse_and_save_record(doc, options)
      patient = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
      Cypress::GoImport.replace_negated_codes(patient, @bundle)
      patient.save
      patient
    rescue
      add_error('File failed import', file_name: options[:file_name])
      nil
    end

    def validate_calculated_results(doc, options)
      mrn, = get_record_identifiers(doc, options)
      return false unless mrn

      record = parse_and_save_record(doc, options)
      return false unless record

      product_test = options['task'].product_test

      # This Logic will need to be updated with CQL calculations
      # TODO fix effectiveDateEnd and effectiveDate in cqm-execution.  effectiveDate is the end of the measurement period
      calc_job = Cypress::CqmExecutionCalc.new([record], product_test.measures, product_test.value_sets_by_oid, options.test_execution.id.to_s,
                                               'effectiveDateEnd': Time.at(product_test.effective_date).in_time_zone.to_formatted_s(:number),
                                               'effectiveDate': Time.at(product_test.measure_period_start).in_time_zone.to_formatted_s(:number))
      results = calc_job.execute
      passed = determine_passed(mrn, results, record, options)
      record.destroy
      passed
    end

    def determine_passed(mrn, results, record, options)
      passed = true
      @measures.each do |measure|
        original_results = QDM::IndividualResult.where('patient_id' => mrn, 'measure_id' => measure.id).first
        new_results = results.select { |arr| arr.measure_id == measure.id && arr.patient_id == record.id }.first
        options[:population_ids] = measure.population_ids
        passed = compare_results(original_results, new_results, options, passed)
      end
      passed
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
        mrn, doc_name, aug_rec = get_record_identifiers(doc, options)
        @found_names << ((@names[doc_name] ? doc_name : nil) || to_doc_name(aug_rec[:first][0], aug_rec[:last][0])) if mrn
        # we still need to validate that the returned record is one of the test records
        # and that it was expected to be returned (ie, in the IPP)
        validate_name(doc_name, options) && validate_expected_results(doc_name, mrn, options)
      else
        super
      end
    end
  end
end
