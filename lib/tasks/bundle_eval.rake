namespace :bundle do
  namespace :eval do
    task setup: :environment

    desc %(Evaluate a bundle for potential 'single measure' calculation issues due to code crosswalk.

    You must identify the bundle version:

    $ rake bundle:eval:code_crosswalk[xxxx.x.x])
    task :code_crosswalk, [:bundle_version] => :setup do |_, args|
      bundle = Bundle.where(version: args.bundle_version).first
      CSV.open('tmp/code_crosswalk.csv', 'w', col_sep: '|') do |csv|
        bundle.measures.each do |measure|
          valuesets = measure.value_sets
          bundle.patients.each do |patient|
            patient.qdmPatient.dataElements.each_with_index do |data_element, de_index|
              cross_walks = {}
              codes = {}
              data_element.dataElementCodes.each do |dec|
                scooped_vs = valuesets.map { |vs| vs.oid if vs.concepts.collect { |vsc| do_codes_match?(dec, vsc) }.include? true }.compact
                next if scooped_vs.blank?

                code_hash = { code: dec['code'], code_system: dec['codeSystemOid'], valuesets: scooped_vs }
                codes[dec['code']] = code_hash
                next unless codes.size.positive?

                cross_walks[dec['code']] = code_hash if codes.values.collect { |cv| cv[:valuesets] == scooped_vs }.include? false
              end
              next if cross_walks.empty?

              calc_diffs = false
              effective_date_end = Time.at(bundle.effective_date).in_time_zone.to_formatted_s(:number)
              effective_date = Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
              options = { 'effectiveDateEnd': effective_date_end, 'effectiveDate': effective_date }
              cw_patient = patient.clone
              cw_patient.save
              original_results = SingleMeasureCalculationJob.perform_now([cw_patient.id.to_s], measure.id.to_s, bundle.id.to_s, options)
              codes.each_value do |cw|
                next if calc_diffs

                cw_patient.qdmPatient.dataElements[de_index].dataElementCodes = [{ 'code' => cw[:code], 'codeSystemOid' => cw[:code_system] }]
                cw_patient.save
                new_results = SingleMeasureCalculationJob.perform_now([cw_patient.id.to_s], measure.id.to_s, bundle.id.to_s, options)
                calc_diffs = are_results_different?(original_results, new_results)
              end
              cw_patient.delete
              csv << [measure.cms_id, "#{patient.givenNames[0]} #{patient.familyName}", de_index, data_element._type, codes] if calc_diffs
            end
          end
        end
      end
    end

    desc %(Compares the calculation results across 2 bundles.  Presumably, both bundles share the same test patients.
    When a difference is found, the compare_calculations.csv will include the patient name and cms_id with differences.

    You must identify two bundle versions:

    $ rake bundle:eval:compare_calculations[xxxx.x.x,xxxx.x.x])
    task :compare_calculations, %i[bundle_version_1 bundle_version_2] => :setup do |_, args|
      first_bundle = Bundle.where(version: args.bundle_version_1).first
      second_bundle = Bundle.where(version: args.bundle_version_2).first
      CSV.open('tmp/compare_calculations.csv', 'w', col_sep: '|') do |csv|
        # Iterate through all patients in both bundles to catch instances where calculations may be nonexistent on one of the bundles
        first_bundle.patients.each do |first_patient|
          second_patient = second_bundle.patients.where(givenNames: first_patient.givenNames, familyName: first_patient.familyName).first
          # Skip if the same patient can't be found in both bundles
          next unless second_patient

          first_patient.calculation_results.each do |fp_cr|
            measure_id = second_bundle.measures.where(cms_id: fp_cr.measure.cms_id).first.id
            sp_cr = second_patient.calculation_results.where(measure_id: measure_id, population_set_key: fp_cr.population_set_key).first
            calc_diffs = sp_cr.nil? ? true : false
            calc_diffs ||= result_different?(fp_cr, sp_cr)
            csv << [fp_cr.measure.cms_id, first_patient.givenNames[0], first_patient.familyName] if calc_diffs
          end
        end
        second_bundle.patients.each do |second_patient|
          first_patient = first_bundle.patients.where(givenNames: second_patient.givenNames, familyName: second_patient.familyName).first
          # Skip if the same patient can't be found in both bundles
          next unless first_patient

          second_patient.calculation_results.each do |sp_cr|
            measure_id = first_bundle.measures.where(cms_id: sp_cr.measure.cms_id).first.id
            fp_cr = first_patient.calculation_results.where(measure_id: measure_id, population_set_key: sp_cr.population_set_key).first
            calc_diffs = sp_cr.nil? ? true : false
            calc_diffs ||= result_different?(sp_cr, fp_cr)
            csv << [sp_cr.measure.cms_id, second_patient.givenNames[0], second_patient.familyName] if calc_diffs
          end
        end
      end
    end

    desc %(Evaluate a bundle for potential disconnects between Diagnosis and Encounter Diagnosis.

    You must identify the bundle version:

    $ rake bundle:eval:code_crosswalk[xxxx.x.x])
    task :find_diagnosis_differences, [:bundle_version] => :setup do |_, args|
      all_vs = {}
      CSV.open('tmp/find_diagnosis_differences.csv', 'w') do |csv|
        bundle = Bundle.where(version: args.bundle_version).first
        bundle.patients.each do |bp|
          # Array of all valuesets used in a patient's condition list
          bp_condition_vs_list = []
          # Array of all valuesets used in a patient's encounters principalDiagnosis and diagnoses
          en_encounter_dx_vs_list = []
          bp.qdmPatient.conditions.each do |c|
            c['dataElementCodes'].each do |dec|
              # check if snomed
              next unless dec['codeSystemOid'] == '2.16.840.1.113883.6.96'

              ValueSet.where('concepts.code' => dec['code']).each do |vs|
                bp_condition_vs_list << vs.oid
              end
            end
          end
          bp.qdmPatient.get_data_elements('encounter', 'performed').each do |c|
            if c.principalDiagnosis && c.principalDiagnosis.codeSystemOid == '2.16.840.1.113883.6.96'
              ValueSet.where('concepts.code' => c.principalDiagnosis.code).each do |vs|
                en_encounter_dx_vs_list << vs.oid
              end
            end
            c.diagnoses&.each do |encounter_diagnosis|
              next unless encounter_diagnosis.codeSystemOid == '2.16.840.1.113883.6.96'

              ValueSet.where('concepts.code' => encounter_diagnosis.code).each do |vs|
                en_encounter_dx_vs_list << vs.oid
              end
            end
          end
          bp_condition_vs_list.uniq!
          en_encounter_dx_vs_list.uniq!
          # Find encounter diagnoses that are not in the patient's condition list
          [en_encounter_dx_vs_list - bp_condition_vs_list].each do |missing_dx_vs|
            missing_dx_vs.each do |missing_vs|
              all_vs[missing_vs] = [] unless all_vs[missing_vs]
              all_vs[missing_vs] << bp.id
            end
          end
        end
        Measure.each do |mes|
          mes.source_data_criteria.each do |criteria|
            next unless criteria._type.eql? 'QDM::Diagnosis'
            next if all_vs[criteria.codeListId].nil?

            all_vs[criteria.codeListId].each do |bp_name|
              patient = Patient.find(bp_name)
              # Print out patients with a missing diagnosis that are relevant to this measure
              next unless patient.measure_relevance_hash[mes.id.to_s]
              next unless patient.measure_relevance_hash[mes.id.to_s]['IPP'] == true

              csv << [mes.cms_id, criteria.codeListId, "#{patient.givenNames[0]} #{patient.familyName}"]
            end
          end
        end
      end
    end

    def do_codes_match?(data_element_code, valueset_code)
      valueset_code['code'] == data_element_code['code'] && valueset_code['code_system_oid'] == data_element_code['codeSystemOid']
    end

    def are_results_different?(original_results, new_results)
      original_results.each do |original_result|
        new_result = new_results.find(population_set_key: original_result.population_set_key).first
        return true unless original_result['DENEX'] == new_result['DENEX']
        return true unless original_result['DENEXCEP'] == new_result['DENEXCEP']
        return true unless original_result['DENOM'] == new_result['DENOM']
        return true unless original_result['IPP'] == new_result['IPP']
        return true unless original_result['MSRPOPL'] == new_result['MSRPOPL']
        return true unless original_result['MSRPOPLEX'] == new_result['MSRPOPLEX']
        return true unless original_result['NUMER'] == new_result['NUMER']
        return true unless original_result['NUMEX'] == new_result['NUMEX']
        return true unless original_result['OBSERV'] == new_result['OBSERV']
      end
      false
    end

    def result_different?(original_result, new_result)
      return true unless original_result['DENEX'] == new_result['DENEX']
      return true unless original_result['DENEXCEP'] == new_result['DENEXCEP']
      return true unless original_result['DENOM'] == new_result['DENOM']
      return true unless original_result['IPP'] == new_result['IPP']
      return true unless original_result['MSRPOPL'] == new_result['MSRPOPL']
      return true unless original_result['MSRPOPLEX'] == new_result['MSRPOPLEX']
      return true unless original_result['NUMER'] == new_result['NUMER']
      return true unless original_result['NUMEX'] == new_result['NUMEX']
      return true unless original_result['OBSERV'] == new_result['OBSERV']

      false
    end
  end
end
