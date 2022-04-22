# frozen_string_literal: true

module Validators
  class CalculatingSmokingGunValidator < SmokingGunValidator
    include Validators::Validator
    def initialize(measures, records, test_id, options = {})
      @measures = measures
      super
    end

    def parse_record(doc, options)
      patient, warnings = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)

      # check for single code negation errors
      product_test = ProductTest.find(@test_id)
      errors = Cypress::QRDAPostProcessor.issues_for_negated_single_codes(patient, @bundle, product_test.measures)
      unit_errors = Cypress::QRDAPostProcessor.issues_for_mismatched_units(patient, @bundle, product_test.measures)
      if product_test.product.c3_test
        errors.each { |e| add_error e, file_name: options[:file_name] }
      else
        errors.each { |e| add_warning e, file_name: options[:file_name], cms: true }
      end
      unit_errors.each { |e| add_warning e, file_name: options[:file_name], cms: true }
      warnings.each { |e| add_warning e.message, file_name: options[:file_name], location: e.location }

      Cypress::QRDAPostProcessor.replace_negated_codes(patient, @bundle)
      patient.bundleId = @bundle.id
      patient
    rescue StandardError
      add_error('File failed import', file_name: options[:file_name])
      nil
    end

    def validate_calculated_results(doc, options)
      mrn, = get_record_identifiers(doc, options)
      return false unless mrn

      record = parse_record(doc, options)
      record.normalize_date_times
      return false unless record

      product_test = options['task'].product_test
      # remove negations that are not for the measures being reported
      valueset_oids = product_test.measures.only('value_set_ids').map { |mes| mes.value_sets.distinct(:oid) }.flatten
      record.nullify_unnessissary_negations(valueset_oids)

      calc_job = Cypress::CqmExecutionCalc.new([record.qdmPatient],
                                               product_test.measures,
                                               options.test_execution.id.to_s,
                                               effectiveDate: Time.at(product_test.measure_period_start).in_time_zone.to_formatted_s(:number))
      results = calc_job.execute(save: false)
      determine_passed(mrn, results, record, options)
    end

    def determine_passed(mrn, results, record, options)
      passed = true
      @measures.each do |measure|
        original_results = CQM::IndividualResult.where('patient_id' => mrn, 'measure_id' => measure.id)
        original_results.each do |original_result|
          new_result = results.select do |arr|
            arr.measure_id == measure.id.to_s &&
              arr.patient_id == record.id.to_s &&
              arr.population_set_key == original_result['population_set_key']
          end.first
          options[:population_set], options[:stratification_id] = measure.population_set_for_key(original_result['population_set_key'])
          passed, issues = original_result.compare_results(new_result, options, passed)
          issues.each do |issue|
            add_error(issue, file_name: options[:file_name])
          end
        end
      end
      passed
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
