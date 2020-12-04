# frozen_string_literal: true

module Validators
  class Cat3PopulationValidator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators::ReportedResultExtractor

    # These are the demographic codes specified in the CMS IG for Payer, Sex, Race and Ethnicity
    REQUIRED_CODES = { 'PAYER' => %w[A B C D],
                       'SEX' => %w[M F],
                       'RACE' => %w[2106-3 2076-8 2054-5 2028-9 1002-5 2131-1],
                       'ETHNICITY' => %w[2135-2 2186-5] }.freeze

    def initialize; end

    def validate(file, options = {})
      document = get_document(file)
      # Set missing codes to false by default
      @missing_codes = { 'PAYER' => false, 'SEX' => false, 'RACE' => false, 'ETHNICITY' => false }
      document.xpath(measure_entry_selector).each do |measure|
        pop_counts = {}
        measure_id = measure.at_xpath(measure_id_selector).value

        measure.xpath(population_selector_from_measure).each do |population|
          code = population.at_xpath(population_name_selector).value
          count = population.at_xpath(population_count_selector).value || 0

          pop_counts[code] = count.to_i
        end
        # If there is a MSRPOPL, test that CV populations are reported correctly
        if pop_counts['MSRPOPL']
          validate_cv_populations(measure_id, pop_counts, options)
        else
          # Otherwise, check proportion population are reported correctly
          validate_populations(measure_id, pop_counts, options)
        end
      rescue StandardError => e
        # do nothing, if we get an exception the file is probably broken in some way
        Rails.logger.error(e)
      end
      validate_population_ids(document, options)
    end

    def validate_populations(measure, pop, options)
      file = options[:file_name]
      # proportion measures, ipp >= denom, denom >= num + denexcp + denex
      ipp = pop['IPP'] || pop['IPOP'] || 0
      denom = pop['DENOM'] || 0
      denex = pop['DENEX'] || 0
      denexcep = pop['DENEXCEP'] || 0
      num = pop['NUMER'] || 0

      if denom > ipp
        add_error("Denominator value #{denom} is greater than Initial Population value #{ipp} for measure #{measure}",
                  location: '/', file_name: file)
      end
      if (num + denex + denexcep) > denom
        add_error("Numerator value #{num} + Denominator Exclusions value #{denex} + Denominator Exceptions value #{denexcep}"\
        " is greater than Denominator value #{denom} for measure #{measure}", location: '/', file_name: file)
      end
    end

    def validate_population_ids(doc, options)
      measure_ids_from_file(doc).each do |measure_id|
        measure = options['test_execution'].task.bundle.measures.find_by(hqmf_id: measure_id.value.upcase)
        measure.population_sets_and_stratifications_for_measure.each do |pop_set_hash|
          results, _errors = extract_results_by_ids(measure, pop_set_hash[:population_set_id], doc, pop_set_hash[:stratification_id])
          measure.population_keys.each do |key|
            validate_demographics(results, key, pop_set_hash, options)
            next if results[key]

            population = measure.population_sets.select { |pset| pset[:population_set_id] == pop_set_hash[:population_set_id] }.first.populations[key]
            add_error("#{key} (#{population['hqmf_id']}) is missing"\
            " for #{measure.cms_id}", location: measure_id.parent.path, file_name: options[:file_name])
          end
        end
      end
    end

    def validate_demographics(reported_result, pop_key, pop_set_hash, options)
      #  Skip demographic validators if population is missing
      # Skip if there is a stratification_id.  Stratifications do not report demographics
      return if reported_result[pop_key].nil? || pop_set_hash[:stratification_id]

      verify_all_codes_reported(reported_result, pop_key, 'PAYER', options) unless @missing_codes['PAYER']
      verify_all_codes_reported(reported_result, pop_key, 'SEX', options) unless @missing_codes['SEX']
      verify_all_codes_reported(reported_result, pop_key, 'RACE', options) unless @missing_codes['RACE']
      verify_all_codes_reported(reported_result, pop_key, 'ETHNICITY', options) unless @missing_codes['ETHNICITY']
    end

    # Verifiy that all demographic codes for a sup_key (e.g., RACE) are present for a pop_key (e.g., DENOM) in a reported result
    def verify_all_codes_reported(reported_result, pop_key, sup_key, options)
      reported_codes = reported_result[:supplemental_data][pop_key][sup_key]
      required_codes = REQUIRED_CODES[sup_key]
      missing_codes = required_codes - reported_codes.keys
      return if missing_codes.empty?

      msg = "For CMS eligible clinicians and eligible professionals programs, all #{sup_key} codes present in the value set must be reported," \
      'even if the count is zero. If an eCQM is episode-based, the count will reflect the patient count rather than the episode count.'
      add_error(msg, file_name: options[:file_name])
      @missing_codes[sup_key] = true
    end

    def validate_cv_populations(measure, pop, options)
      file = options[:file_name]
      # CVT measures, IPP >= MSRPOPL >= OBSERV
      msrpopl = pop['MSRPOPL'] || 0
      observ = pop['OBSERV'] || 0

      if msrpopl > ipp
        add_error("Measure Population value #{msrpopl} is greater than Initial Population value #{ipp} for  "\
        "measure #{measure}", '/', location: '/', file_name: file)
      end
      if observ > msrpopl
        add_error("Measure observvations value #{observ} cannot be greater than Measure Population value #{msrpopl}"\
        " for measure #{measure}", '/', location: '/', file_name: file)
      end
    end

    def measure_entry_selector
      '/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component' \
        "/cda:section[./cda:templateId[@root='2.16.840.1.113883.10.20.27.2.1']]/cda:entry/cda:organizer"
    end

    def measure_id_selector
      'cda:id/@extension'
    end

    def population_selector_from_measure
      "cda:component/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.27.3.5']]"
    end

    def population_name_selector
      'cda:value/@code'
    end

    def measure_ids_from_file(doc)
      measure_ids = doc.xpath("//cda:entry/cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1']]" \
        "/cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']" \
        "/cda:id[@root='2.16.840.1.113883.4.738']/@extension")
      return nil unless measure_ids

      measure_ids
    end
  end
end
