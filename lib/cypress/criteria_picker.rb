module Cypress
  class CriteriaPicker
    #TODO R2P: pick filter criteria using new model
    def self.races(patient, _options = {})
      race_element = patient.get_data_elements('patient_characteristic','race').first
      [race_element.dataElementCodes.first.code]
    end

    def self.ethnicities(patient, _options = {})
      ethnicity_element = patient.get_data_elements('patient_characteristic','ethnicity').first
      [ethnicity_element.dataElementCodes.first.code]
    end

    def self.genders(patient, _options = {})
      [patient.gender]
    end

    def self.payers(patient, _options = {})
      #TODO R2P: Check just getting first ip name? (not all)
      [JSON.parse(patient.extendedData.insurance_providers).first['name']]
    end

    def self.age(patient, options = {})
      age = patient.age_at(options[:effective_date])
      prng = options[:prng]

      # select min or max randomly
      # if max, shift age criteria up, if min shift age down
      # ex, the patient is 33, if we pick min set it to 30, if max set it to 36

      min_age = age - prng.rand(2..10)
      max_age = age + prng.rand(2..10)

      return { max: max_age } if min_age <= 1

      [{ min: min_age }, { max: max_age }].sample(random: prng)
    end

    def self.providers(patient, options = {})
      patient.lookup_provider(options[:incl_addr])
    end

    def self.problems(_record, options = {})
      problem_oid = lookup_problem(options[:measures], options[:patients], options[:prng])
      { oid: [problem_oid], hqmf_ids: hqmf_oids_for_problem(problem_oid, options[:measures]) }
    end

    def self.lookup_problem(measures, records, prng)
      measure = measures.first
      code_list_id = fallback_id = ''
      # determine which data criteira are diagnoses, and make sure we choose one that one of our records has
      # if we can't find one that matches a record, just use any diagnosis (fallback)

      #randomize before iterating
      measure.hqmf_document.source_data_criteria.to_a.shuffle(random: prng).each do |_criteria, cr_hash|
        #find diagnosis criteria in measure
        next unless cr_hash.definition.eql? 'diagnosis'
        fallback_id = cr_hash['code_list_id']
        value_set = HealthDataStandards::SVS::ValueSet.where(oid: cr_hash['code_list_id']).first

        #search through records for diagnosis criteria
        next unless find_problem_in_records(records, value_set)
        code_list_id = cr_hash['code_list_id']
        break
      end

      code_list_id.empty? ? fallback_id : code_list_id
    end

    def self.find_problem_in_records(records, value_set)
      #go through all record diagnoses
      records.each do |r|
        #TODO: check condition sufficient?
        r.conditions.each do |c|
          c['dataElementCodes'].each do |dec|
            #check if snomed
            next unless dec['codeSystem'] == 'SNOMED-CT'
            #check code against all valueset concepts
            value_set['concepts'].each do |concept|
              return true if concept['code']==dec['code']
            end
          end
        end
      end
      false #no record diagnosis matches a code in this valueset

    end

    def self.hqmf_oids_for_problem(problem_oid, measures)
      measure = measures.first
      hqmf_oids = []
      measure.hqmf_document.source_data_criteria.each do |_criteria, cr_hash|
        next unless cr_hash.key?('code_list_id') && cr_hash.code_list_id == problem_oid
        hqmf_oid = HQMF::DataCriteria.template_id_for_definition(cr_hash['definition'], cr_hash['status'], cr_hash['negation'])
        hqmf_oid ||= HQMF::DataCriteria.template_id_for_definition(cr_hash['definition'], cr_hash['status'], cr_hash['negation'], 'r2')
        hqmf_oids << hqmf_oid
      end
      hqmf_oids.uniq
    end
  end
end
