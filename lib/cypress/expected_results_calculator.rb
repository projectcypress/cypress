module Cypress
  class ExpectedResultsCalculator

    def initialize(product_test)
      @product_test = product_test
      @patient_sup_map = {}
      @measure_result_hash = {}
      @product_test.patients.each do |patient|
        @patient_sup_map[patient.id] = {}
        @patient_sup_map[patient.id]['SEX'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.55')[0].dataElementCodes[0].code
        @patient_sup_map[patient.id]['RACE'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.59')[0].dataElementCodes[0].code
        @patient_sup_map[patient.id]['ETHNICITY'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.56')[0].dataElementCodes[0].code
        @patient_sup_map[patient.id]['PAYER'] = 1
      end
    end


    def aggregate_results_for_measures(measures)
      measures.each do |measure|
        @measure_result_hash[measure.key] = {}
        aggregate_results_for_measure(measure)
      end
      @measure_result_hash
    end

    def aggregate_results_for_measure(measure)
      individual_results = QDM::IndividualResult.where('measure_id' => measure._id, 'extendedData.correlation_id' => @product_test.id.to_s)
      measure_populations = %w[DENOM NUMER DENEX DENEXCEP IPP MSRPOPL MSRPOPLEX]
      @measure_result_hash[measure.key]['supplemental_data'] = {}
      measure_populations.each do |pop|
        @measure_result_hash[measure.key][pop] = 0
      end
      individual_results.each do |ir|
        measure_populations.each do |pop|
          next if ir[pop].nil? || ir[pop] == 0
          @measure_result_hash[measure.key][pop] += ir[pop]
          increment_sup_info(@patient_sup_map[ir.patient_id], pop, @measure_result_hash[measure.key])
        end
      end
      @measure_result_hash[measure.key]['measure_id'] = measure.hqmf_id
      @measure_result_hash[measure.key]['population_ids'] = measure.population_ids
      create_query_cache_object(@measure_result_hash[measure.key], measure)
    end

    def increment_sup_info(patient_sup, pop, single_measure_result_hash)
      if !single_measure_result_hash['supplemental_data'][pop]
        single_measure_result_hash['supplemental_data'][pop] = { 'RACE' => {}, 'ETHNICITY' => {}, 'SEX' => {}, 'PAYER' => {} }
      end
      patient_sup.keys.each do |sup_type|
        add_or_increment_code(pop, sup_type, patient_sup[sup_type], single_measure_result_hash)
      end
    end

    def add_or_increment_code(pop, sup_type, code, single_measure_result_hash)
      if single_measure_result_hash['supplemental_data'][pop][sup_type][code]
        single_measure_result_hash['supplemental_data'][pop][sup_type][code] += 1
      else
        single_measure_result_hash['supplemental_data'][pop][sup_type][code] = 1
      end
    end

    def create_query_cache_object(result, measure)
      qco = result
      qco['test_id'] = @product_test.id
      qco['effective_date'] = @product_test.effective_date
      qco['sub_id'] = measure.sub_id if measure.sub_id
      Mongoid.default_client["query_cache"].insert_one(qco)
    end

  end
 end