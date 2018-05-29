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
      filters.each do |k,v|
        #return true if patient is missing any filter item
        #TODO: filter for age and problem (purposefully no prng)
        if (k=='age')
          #{}"age"=>{"min"=>70}}
          #compare integers?? or dates?
          return true if v.key?('min') && patient.age_at(params[:effective_date]) < v['min']
          return true if v.key?('max') && patient.age_at(params[:effective_date]) > v['max']
        elsif (k=='payers')
          #missing payer if value doesn't match any payer name (of multiple providers)
          return true if !JSON.parse(patient.extendedData.insurance_providers).map{|ip| ip['name']}.include?(v.first)

        elsif (k=='problems')
          patient_missing_problems(patient, v)
          #{"oid"=>["2.16.840.1.113883.3.666.5.748"], "hqmf_ids"=>["2.16.840.1.113883.10.20.28.3.110"]}
        elsif (k=='providers')
          # {"npis"=>["1315796189"], "tins"=>["136171912"], "addresses"=>[{"street"=>["815 Parisian Stream Locks"], "city"=>"Larsonville", "state"=>"ID", "zip"=>"83270", "country"=>"US"}]}
          # byebug #product_test.patients[4].lookup_provider(include_address:true)['addresses']==product_test.options['filters']['providers']['addresses']
          provider = patient.lookup_provider(include_address:true)
          # byebug
          v.each{|key,val| return true if val !=provider[key]}
        else
          #races, ethnicities, genders, providers
          return true if v != Cypress::CriteriaPicker.send(k, patient, params)
        end
      end
      false
    end

    def self.patient_missing_problems(patient, problem)
      #TODO: first... different versions of value set... which version do we want?
      #2.16.840.1.113883.3.666.5.748
      value_set = HealthDataStandards::SVS::ValueSet.where(oid: problem['oid'].first).first
      !Cypress::CriteriaPicker.find_problem_in_records([patient], value_set)
    end
  end
end
