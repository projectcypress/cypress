# frozen_string_literal: true

# Validator to check that all populations are reported for a measure (e.g., IPP, DENOM) and that all demographic codes are
# reported within the populations

module Validators
  class CMSPopulationCountValidator < QrdaFileValidator
    include Validators::Validator
    include CqmValidators::ReportedResultExtractor

    # These are the demographic codes specified in the CMS IG for Payer, Sex, Race and Ethnicity
    REQUIRED_CODES = { 'PAYER' => %w[A B C D],
                       'SEX' => %w[M F],
                       'RACE' => %w[2106-3 2076-8 2054-5 2028-9 1002-5 2131-1],
                       'ETHNICITY' => %w[2135-2 2186-5] }.freeze

    def initialize; end

    def validate(file, options = {})
      @document = get_document(file)
      # Set missing codes to false by default
      @missing_codes = { 'PAYER' => false, 'SEX' => false, 'RACE' => false, 'ETHNICITY' => false }
      # Iterate over every measure in a QRDA document
      measure_ids_from_file.each do |hqmf_id|
        # Find the measure in the database
        measure = Measure.where(hqmf_id: hqmf_id)
        # Skip if it doesn't exist.  It is not incorrect to include additional measures.
        next if measure.empty?

        measure = measure.first
        measure.population_sets_and_stratifications_for_measure.each do |pop_set_hash|
          # Extract reported results for each population set for the measure
          reported_result, _errors = extract_results_by_ids(measure, pop_set_hash[:population_set_id], @document, pop_set_hash[:stratification_id])
          measure.population_keys.each do |pop_key|
            # Return an error message if the document is missing a resported result for this population key
            add_error("Missing #{pop_key} for #{measure.cms_id}", file_name: options[:file_name]) if reported_result[pop_key].nil?
            # Skip demographic validators if population is missing
            next if reported_result[pop_key].nil?

            # Skip demographic validators if a code is already found to be missing. Otherwise, validate that all demographic codes are present
            verify_all_codes_reported(reported_result, pop_key, 'PAYER', options) unless @missing_codes['PAYER']
            verify_all_codes_reported(reported_result, pop_key, 'SEX', options) unless @missing_codes['SEX']
            verify_all_codes_reported(reported_result, pop_key, 'RACE', options) unless @missing_codes['RACE']
            verify_all_codes_reported(reported_result, pop_key, 'ETHNICITY', options) unless @missing_codes['ETHNICITY']
          end
        end
      end
    end

    private

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

    def measure_ids_from_file
      measure_ids = @document.xpath("//cda:entry/cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1']]" \
        "/cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']" \
        "/cda:id[@root='2.16.840.1.113883.4.738']/@extension").map(&:value).map(&:upcase)
      return nil unless measure_ids

      measure_ids
    end
  end
end
