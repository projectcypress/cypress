# frozen_string_literal: true

module Validators
  class CalculatingSmokingGunValidator < SmokingGunValidator
    include Validators::Validator
    def initialize(measures, records, test_id, options = {})
      @measures = measures
      super
    end

    # rubocop:disable Metrics/AbcSize
    def parse_record(doc, options)
      patient, warnings = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)

      # check for single code negation errors
      product_test = ProductTest.find(@test_id)
      errors = Cypress::QrdaPostProcessor.issues_for_negated_single_codes(patient, @bundle, product_test.measures)
      unit_errors = Cypress::QrdaPostProcessor.issues_for_mismatched_units(patient, @bundle, product_test.measures)
      if product_test.product.c3_test
        errors.each { |e| add_error e, file_name: options[:file_name] }
      else
        errors.each { |e| add_warning e, file_name: options[:file_name], cms: true }
      end
      unit_errors.each { |e| add_warning e, file_name: options[:file_name], cms: true }
      warnings.each { |e| add_warning e.message, file_name: options[:file_name], location: e.location }

      Cypress::QrdaPostProcessor.replace_negated_codes(patient, @bundle)
      Cypress::QrdaPostProcessor.remove_invalid_qdm_56_data_types(patient) if @bundle.major_version.to_i > 2021
      patient.bundleId = @bundle.id
      patient
    rescue StandardError
      add_error('File failed import', file_name: options[:file_name])
      nil
    end
    # rubocop:enable Metrics/AbcSize

    def validate_calculated_results(doc, options)
      mrn, _doc_name, _aug_rec, telecoms = get_record_identifiers(doc, options)
      return false unless mrn

      validate_telecoms(mrn, telecoms, options)
      record = parse_record(doc, options)
      record.normalize_date_times
      return false unless record

      product_test = options['task'].product_test
      # remove negations that are not for the measures being reported
      valueset_oids = product_test.measures.only('value_set_ids').map { |mes| mes.value_sets.distinct(:oid) }.flatten
      record.nullify_unnessissary_negations(valueset_oids)

      cec_options = { effectiveDate: product_test.start_date.to_formatted_s(:number) }
      # If the product_test start_date is january 1st, you don't need to pass in the effectiveDateEnd, the calculation engine will take care of it
      cec_options[:effectiveDateEnd] = product_test.end_date.to_formatted_s(:number) if product_test.start_date.yday != 1
      calc_job = Cypress::CQMExecutionCalc.new([record.qdmPatient],
                                               product_test.measures,
                                               options.test_execution.id.to_s,
                                               cec_options)
      results = calc_job.execute(save: false)
      determine_passed(mrn, results, record, options)
    end

    def validate_telecoms(mrn, telecoms, options)
      original_patient = Patient.find(mrn)
      original_patient.telecoms.each do |telecom|
        expected_phone = TelephoneNumber.parse(telecom.value, :us).e164_number
        next if telecoms[:phone_list].any? { |tel| tel == expected_phone }

        add_error("Phone number #{telecom.value} could not be found in file.", file_name: options[:file_name])
      end
      return unless original_patient.email
      return if telecoms[:email_list].include? original_patient.email

      add_error("Email #{original_patient.email} could not be found in file.", file_name: options[:file_name])
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
