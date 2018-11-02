module Cypress
  class PatientFilter
    def self.filter(records, filters, options)
      filtered_patients = []
      records.each do |patient|
        filtered_patients << patient unless patient_missing_filter(patient, filters, options)
      end
      filtered_patients
    end

    def self.patient_missing_filter(patient, filters, params)
      # byebug
      filters.each do |k, v|
        # return true if patient is missing any filter item
        # TODO: filter for age and problem (purposefully no prng)
        if k == 'age'
          # {}"age"=>{"min"=>70}}
          # TODO: compare integers?? or dates?
          return true if check_age(v, patient, params)
        elsif k == 'payers'
          # missing payer if value doesn't match any payer name (of multiple providers)
          return true unless match_payers(v, patient)
        elsif k == 'problems'
          return patient_missing_problems(patient, v)
        elsif k == 'providers'
          provider = patient.lookup_provider(include_address: true)
          v.each { |key, val| return true if val != provider[key] }
        elsif v != Cypress::CriteriaPicker.send(k, patient, params)
          # races, ethnicities, genders, providers
          return true
        end
      end
      false
    end

    def self.match_payers(v, patient)
      JSON.parse(patient.extendedData.insurance_providers).map { |ip| ip['name'] }.include?(v.first)
    end

    def self.check_age(v, patient, params)
      return true if v.key?('min') && patient.age_at(params[:effective_date]) < v['min']
      return true if v.key?('max') && patient.age_at(params[:effective_date]) > v['max']

      false
    end

    def self.patient_missing_problems(patient, problem)
      # TODO: first... different versions of value set... which version do we want?
      # 2.16.840.1.113883.3.666.5.748
      value_set = ValueSet.where(oid: problem['oid'].first).first
      !Cypress::CriteriaPicker.find_problem_in_records([patient], value_set)
    end
  end
end
