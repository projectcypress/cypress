module Cypress
  class RecordFilter
    def self.filter(records, filters, options)
      records.where create_query(filters, options)
    end

    def self.create_query(input_filters, options)
      query = {}

      if input_filters['races']
        query['race.code'] = { '$in' => input_filters['races'] }
      end

      if input_filters['ethnicities']
        query['ethnicity.code'] = { '$in' => input_filters['ethnicities'] }
      end

      if input_filters['genders']
        query['gender'] = { '$in' => input_filters['genders'] }
      end

      if input_filters['payers']
        query['insurance_providers'] = { '$elemMatch' => { 'payer.name' => { '$in' => input_filters['payers'] } } }
      end

      if input_filters['age']
        create_age_query(query, input_filters['age'], options)
      end

      if input_filters['problems']
        create_problem_query(query, input_filters['problems'])
      end

      # STILL TODO:
      # provider tin
      # provider npi
      # provider type
      # practice site addr

      query
    end

    def self.create_age_query(query, age_filter, options)
      # filter only by a single age range, can be age < max, age > min, or min < age < max
      effective_date = Time.at(options[:effective_date]).utc

      if age_filter['max']
        age_max = age_filter['max']
        start_of_day = Time.utc(effective_date.year, effective_date.month, effective_date.day, 0, 0, 0)
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

        query[:birthdate.gte] = req_birthdate
      end
      if age_filter['min']
        age_min = age_filter['min']
        end_of_day = Time.utc(effective_date.year, effective_date.month, effective_date.day, 23, 59, 59)
        # Here we use the end of the effective date as the comparison point,
        # so that the entire date is included within the range.
        # The filter query essentially becomes:
        # :birthdate <= 01/01/20xx 23:59:59

        req_birthdate = end_of_day - age_min.years

        query[:birthdate.lte] = req_birthdate
      end
    end

    def self.create_problem_query(query, problem_filters)
      # given a value set, find conditions and procedures where the diagnosis code matches

      # mongo has no joins or inner querying so we have to first fetch the given codes
      # then put those into the query to be returned

      # I think this whole section ending in relevant_codes
      # could possibly be combined into 1 mongo query that does everything
      value_sets = HealthDataStandards::SVS::ValueSet.where('oid' => { '$in' => problem_filters })

      code_sets = value_sets.pluck('concepts')

      relevant_codes = []

      code_sets.each do |code_set|
        code_set.each do |code|
          # problems come from SNOMED, per the rule
          relevant_codes << code['code'] if code['code_system'] == '2.16.840.1.113883.6.96'
        end
      end

      relevant_codes.uniq!

      problem_subquery = { '$elemMatch' => { 'codes.SNOMED-CT' => { '$in' => relevant_codes } } }

      conditions = { 'conditions' => problem_subquery }
      procedures = { 'procedures' => problem_subquery }
      encounters = { 'encounters' => problem_subquery }

      # TODO: this can be dangerous, what if something else needs an OR
      query['$or'] = [conditions, procedures, encounters]
    end
  end
end
