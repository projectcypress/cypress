# frozen_string_literal: true

module Validators
  class Cat3PopulationValidator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators::ReportedResultExtractor

    def initialize; end

    def validate(file, options = {})
      document = get_document(file)
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
        validate_population_ids(document, options)

      rescue StandardError => e
        # do nothing, if we get an exception the file is probably broken in some way
        Rails.logger.error(e)
      end
    end

    def validate_population_ids(doc, options)
      doc_measure_nodes = doc.xpath(measure_hqmf_id_selector)
      doc_measure_nodes.each do |measure_node|
        measure = options['test_execution'].task.bundle.measures.find_by(hqmf_id: measure_node.value.upcase)
        measure.population_sets_and_stratifications_for_measure.each do |ps_hash|
          reported_result, _errors = extract_results_by_ids(measure, ps_hash[:population_set_id], doc, ps_hash[:stratification_id])
          measure.population_keys.each do |pop_key|
            next if reported_result[pop_key]

            population_set = measure.population_sets.select { |ps| ps[:population_set_id] == ps_hash[:population_set_id] }.first.populations[pop_key]
            msg = "#{pop_key} (#{population_set['hqmf_id']}) is missing from entry for #{measure.cms_id}"
            add_error(msg, location: measure_node.parent.path, file_name: options[:file_name])
          end
        end
      end
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

    def measure_hqmf_id_selector
      '/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry' \
        "/cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1']]/cda:reference[@typeCode='REFR']" \
        "/cda:externalDocument[@classCode='DOC']/cda:id[@root='2.16.840.1.113883.4.738']/@extension"
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

    def population_count_selector
      "cda:entryRelationship/cda:observation[./cda:templateId[@root='2.16.840.1.113883.10.20.27.3.3']"\
      " and ./cda:code[@code='MSRAGG'] and ./cda:methodCode[@code='COUNT']]/cda:value/@value"
    end
  end
end
