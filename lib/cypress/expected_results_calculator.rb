module Cypress
  class ExpectedResultsCalculator

    def initialize(patients)
      @patient_sup_map = {}
      @measure_result_hash = {}
      patients.each do |patient|
        @patient_sup_map[patient.id] = {}
        @patient_sup_map[patient.id]['SEX'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.55')[0].dataElementCodes[0].code
        @patient_sup_map[patient.id]['RACE'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.59')[0].dataElementCodes[0].code
        @patient_sup_map[patient.id]['ETHNICITY'] = patient.get_by_hqmf_oid('2.16.840.1.113883.10.20.28.3.56')[0].dataElementCodes[0].code
        @patient_sup_map[patient.id]['PAYER'] = 1
      end
    end

    def aggregate_results(individual_results, population_ids)
      @measure_result_hash['population_ids'] = population_ids
      measure_populations = %w[DENOM NUMER DENEX DENEXCEP IPP MSRPOPL MSRPOPLEX]
      @measure_result_hash['supplemental_data'] = {}
      measure_populations.each do |pop|
        @measure_result_hash[pop] = 0
      end
      individual_results.each do |ir|
        measure_populations.each do |pop|
          next if ir[pop].nil? || ir[pop] == 0
          @measure_result_hash[pop] += ir[pop]
          increment_sup_info(@patient_sup_map[ir.patient], pop)
        end
      end
      @measure_result_hash
    end

    def increment_sup_info(patient_sup, pop)
      if !@measure_result_hash['supplemental_data'][pop]
        @measure_result_hash['supplemental_data'][pop] = { 'RACE' => {}, 'ETHNICITY' => {}, 'SEX' => {}, 'PAYER' => {} }
      end
      patient_sup.keys.each do |sup_type|
        add_or_increment_code(pop, sup_type, patient_sup[sup_type])
      end
    end

    def add_or_increment_code(pop, sup_type, code)
      if @measure_result_hash['supplemental_data'][pop][sup_type][code]
        @measure_result_hash['supplemental_data'][pop][sup_type][code] += 1
      else
        @measure_result_hash['supplemental_data'][pop][sup_type][code] = 1
      end
    end
  end
 end

