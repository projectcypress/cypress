module Cypress
  class RecordFilter
    def self.filter(records, filters, options)
      records.where create_query(filters, options)
    end

    def self.create_query(input_filters, options)
      query_pieces = build_demographic_query(input_filters)

      if input_filters['payers']
        query_pieces << build_payer_query(input_filters['payers'])
      end

      if input_filters['age']
        query_pieces << build_age_query(input_filters['age'], options)
      end

      if input_filters['problems']
        query_pieces << build_problem_query(input_filters['problems'], options)
      end

      if input_filters['providers']
        prov_query = build_provider_query(input_filters['providers'], options)
        query_pieces << prov_query unless prov_query == {}
      end

      { '$and' => query_pieces }
    end

    def self.build_demographic_query(input_filters)
      query_pieces = []

      if input_filters['races']
        query_pieces << { 'race.code' => { '$in' => input_filters['races'] } }
      end

      if input_filters['ethnicities']
        query_pieces << { 'ethnicity.code' => { '$in' => input_filters['ethnicities'] } }
      end

      if input_filters['genders']
        query_pieces << { 'gender' => { '$in' => input_filters['genders'] } }
      end

      query_pieces
    end

    def self.build_payer_query(payer_list)
      { 'insurance_providers' => { '$elemMatch' => { 'payer.name' => { '$in' => payer_list } } } }
    end

    def self.build_age_query(age_filter, options)
      # filter only by a single age range, can be age < max, age > min, or min < age < max
      effective_date = Time.at(options[:effective_date]).in_time_zone

      age_query = {}

      if age_filter['max']
        age_max = age_filter['max']
        start_of_day = Time.local(effective_date.year, effective_date.month, effective_date.day, 0, 0, 0).in_time_zone
        # Here we use the start of the effective date as the comparison point,
        # so that the entire date is included within the range.
        # The filter query essentially becomes:
        # :birthdate >= 01/01/20xx 00:00:00
        # To filter by a maximum age, we need to go back a year further than the age, minus one day.
        # For example: Patient birthdate 1/1/2000 , Effective Date 11/13/2015, Max Age 15
        # We really need to get everyone who is less than 16, so we go back 16 years to 11/13/1999
        # plus one day to 11/14/1999. Anyone born on or after this date is 15 or less,
        # anyone born before this is 16+ so gets excluded.

        req_birthdate = start_of_day - (age_max + 1).years + 1.day

        age_query[:birthdate.gte] = req_birthdate
      end
      if age_filter['min']
        age_min = age_filter['min']
        end_of_day = Time.local(effective_date.year, effective_date.month, effective_date.day, 23, 59, 59).in_time_zone
        # Here we use the end of the effective date as the comparison point,
        # so that the entire date is included within the range.
        # The filter query essentially becomes:
        # :birthdate <= 01/01/20xx 23:59:59

        req_birthdate = end_of_day - age_min.years

        age_query[:birthdate.lte] = req_birthdate
      end

      age_query
    end

    def self.build_problem_query(problem_filters, options)
      # given a value set, find conditions and procedures where the diagnosis code matches

      # mongo has no joins or inner querying so we have to first fetch the given codes
      # then put those into the query to be returned

      # I think this whole section ending in relevant_codes
      # could possibly be combined into 1 mongo query that does everything
      value_sets = HealthDataStandards::SVS::ValueSet.where('bundle_id' => options[:bundle_id], 'oid' => { '$in' => problem_filters[:oid] })

      code_sets = value_sets.pluck('concepts')

      relevant_codes = []

      code_sets.each do |code_set|
        code_set.each do |code|
          # problems come from SNOMED, per the rule
          relevant_codes << code['code'] if code['code_system'] == '2.16.840.1.113883.6.96'
        end
      end

      relevant_codes.uniq!
      problem_subquery = { '$elemMatch' => { 'oid' => { '$in' => problem_filters[:hqmf_ids] }, 'codes.SNOMED-CT' => { '$in' => relevant_codes } } }

      conditions = { 'conditions' => problem_subquery }
      procedures = { 'procedures' => problem_subquery }
      encounters = { 'encounters' => problem_subquery }

      { '$or' => [conditions, procedures, encounters] }
    end

    def self.build_provider_query(input_filters, options)
      providers = Cypress::ProviderFilter.filter(Provider.all, input_filters, options)

      provider_ids = providers.pluck(:_id)

      return {} if provider_ids.count == 0

      provider_ids.collect! { |pid| BSON::ObjectId(pid) }

      { 'provider_performances' => { '$elemMatch' => { 'provider_id' => { '$in' => provider_ids } } } }
    end
  end
end
