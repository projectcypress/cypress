# The Patient model is an extension of app/models/qdm/patient.rb as defined by CQM-Models.
Patient = QDM::Patient

module QDM
  class Patient

    def destroy
      calculation_results.destroy
      delete
    end

    def product_test
      ProductTest.where('_id' => extendedData[:correlation_id]).most_recent
    end

    def bundle
      if !self['bundle_id'].nil?
        HealthDataStandards::CQM::Bundle.find(self['bundle_id'])
      elsif !extendedData[:correlation_id].nil?
        ProductTest.find(extendedData[:correlation_id]).bundle
      end
    end

    def age_at(date)
      dob = Time.at(birthDatetime).in_time_zone
      date.year - dob.year - (date.month > dob.month || (date.month == dob.month && date.day >= dob.day) ? 0 : 1)
    end

    def original_patient
      if self['original_medical_record_number']
        bundle.patients.where('extendedData.medical_record_number' => self['original_medical_record_number']).first
      end
    end

    def calculation_results
      # TODO CQL: update result model
      QDM::IndividualResult.where('patient_id' => id).where('IPP'.to_sym.gt => 0)
    end

    # R2P TODO: where to get provider_performances from
    # def lookup_provider(include_address = nil)
    #   provider = Provider.find(provider_performances.first['provider_id'])
    #   addresses = []
    #   provider.addresses.each do |address|
    #     addresses << { 'street' => address.street, 'city' => address.city, 'state' => address.state, 'zip' => address.zip,
    #                    'country' => address.country }
    #   end
    #
    #   return { 'npis' => [provider.npi], 'tins' => [provider.tin], 'addresses' => addresses } if include_address
    #   { 'npis' => [provider.npi], 'tins' => [provider.tin] }
    # end

    def duplicate_randomization(random: Random.new)
      patient = clone
      changed = { medical_record_number: medical_record_number, first: [first_names, first_names], last: [familyName, familyName] }
      patient, changed = randomize_patient_name_or_birth(patient, changed, random: random)
      randomize_demographics(patient, changed, random: random)
    end
    #
    # private
    #
    #TODO R2P: use private keyword?
    def first_names
      givenNames.join(' ')
    end

    def randomize_patient_name_or_birth(patient, changed, random: Random.new)
      case random.rand(3) # random chooses which part of the patient is modified
      when 0 # first name
        patient = randomize_patient_name_first(patient, random: random)
        changed[:first] = [first_names, patient.first_names]
      when 1 # last name
        patient = randomize_patient_name_last(patient, random: random)
        changed[:last] = [givenName, patient.givenName]
      when 2 # birthdate
        patient.birthDatetime = DateTime.strptime(patient.birthDatetime.to_s, '%s').change(
          case random.rand(3)
          when 0 then { day: 1, month: 1 }
          when 1 then { day: random.rand(28) + 1 }
          when 2 then { month: random.rand(12) + 1 }
          end
        ).strftime('%s').to_i
        changed[:birthdate] = [birthDatetime, patient.birthDatetime]
      end
      [patient, changed]
    end

    def randomize_patient_name_first(patient, random: Random.new)
      case random.rand(3) # random chooses how to modify the field
      when 0 then patient.givenNames = [patient.givenNames[0][0]] # replace with only first initial
      when 1
        rand_idx = random.rand(patient.givenNames.count)
        patient.givenNames[rand_idx] = replace_random_char(patient.givenNames[rand_idx].clone, random: random) # insert incorrect letter
      when 2 # nickname
        givenNames.each_index do |idx|
          nicknames = NAMES_RANDOM['nicknames'][patient.gender][patient.givenNames[idx]]
          #if no nicknames, use first initial
          patient.givenNames[idx] = nicknames.blank? ? patient.givenNames[idx][0] : nicknames.sample(random: random)
        end
      end
      patient
    end

    def gender
      gender_chars = get_data_elements('patient_characteristic', 'gender')
      if gender_chars && gender_chars.any? && gender_chars.first.dataElementCodes &&
        gender_chars.first.dataElementCodes.any?
        gender_chars.first.dataElementCodes.first[:code]
      else
        patient.extendedData.notes.downcase.include?("female") ? 'F' : 'M'
      end
    end

    def randomize_patient_name_last(patient, random: Random.new)
      case random.rand(2)
      when 0 then patient.familyName = patient.familyName[0] # replace with initial
      when 1 then patient.familyName  = replace_random_char(patient.familyName.clone, random: random) # insert incorrect letter
      end
      patient
    end

    def replace_random_char(name, random: Random.new)
      lowercases = ('a'..'z').to_a
      lsamples = lowercases.sample(2, random: random)
      name_pos = random.rand(name.length - 1) + 1
      name[name_pos] = name[name_pos] != lsamples[0] ? lsamples[0] : lsamples[1]
      name
    end

    def randomize_demographics(patient, changed, random: Random.new)
      # TODO R2P: demographics from patient model
      # case random.rand(3) # now, randomize demographics
      # when 0 # gender
      #   rec.gender = %w[M F].sample(random: random)
      #   changed[:gender] = [gender, rec.gender]
      # when 1 # race
      #   rec.race = APP_CONSTANTS['randomization']['races'].sample(random: random)
      #   changed[:race] = [race.code, rec.race.code]
      # when 2 # ethnicity
      #   rec.ethnicity = APP_CONSTANTS['randomization']['ethnicities'].sample(random: random)
      #   changed[:ethnicity] = [ethnicity.code, rec.ethnicity.code]
      # end
      [patient, changed, self]
    end

    #
    # HDS helpers
    #

    # def self.update_or_create(data)
    #   existing = Record.where(medical_record_number: data.medical_record_number).first
    #   if existing
    #     existing.update_attributes!(data.attributes.except('_id'))
    #     existing
    #   else
    #     data.save!
    #     data
    #   end
    # end
    #
    # def providers
    #   provider_performances.map {|pp| pp.provider }
    # end
    #
    # def over_18?
    #   Time.at(birthdate) < Time.now.years_ago(18)
    # end
    #
    # def entries_for_oid(oid)
    #   matching_entries_by_section = Sections.map do |section|
    #     section_entries = self.send(section)
    #     if section_entries.present?
    #       section_entries.find_all { |entry| (entry.respond_to? :oid) ? entry.oid == oid : false}
    #     else
    #       []
    #     end
    #   end
    #   matching_entries_by_section.flatten
    # end
    #
    # def entries
    #   Sections.map do |section|
    #     self.send(section)
    #   end.flatten
    # end
    #
    # memoize :entries_for_oid
    #
    # # Remove duplicate entries from a section based on cda_identifier or id.
    # # This method may lose information because it does not compare entries
    # # based on clinical content
    # def dedup_section_ignoring_content!(section)
    #   unique_entries = self.send(section).uniq do |entry|
    #     entry.references.each do |ref|
    #       ref.resolve_referenced_id
    #     end
    #     entry.identifier
    #   end
    #   self.send("#{section}=", unique_entries)
    # end
    # def dedup_section_merging_codes_and_values!(section)
    #   unique_entries = {}
    #   self.send(section).each do |entry|
    #     entry.references.each do |ref|
    #       ref.resolve_referenced_id
    #     end
    #     if unique_entries[entry.identifier]
    #       unique_entries[entry.identifier].codes = unique_entries[entry.identifier].codes.deep_merge(entry.codes){ |key, old, new| Array.wrap(old) + Array.wrap(new) }
    #       unique_entries[entry.identifier].values.concat(entry.values)
    #     else
    #       unique_entries[entry.identifier] = entry
    #     end
    #
    #   end
    #   self.send("#{section}=", unique_entries.values)
    # end
    #
    # def dedup_section!(section)
    #   [:encounters, :procedures, :results].include?(section) ? dedup_section_merging_codes_and_values!(section) : dedup_section_ignoring_content!(section)
    # end
    # def dedup_record!
    #   Record::Sections.each {|section| self.dedup_section!(section)}
    # end
    #
    def shift_dates(date_diff)
      self.birthDatetime = (self.birthDatetime.nil?) ? nil : self.birthDatetime + date_diff
      #TODO R2P: are provider_performances still being used?
      #TODO R2P: priority 1.2 (time shift should be implemented in model)
      # self.provider_performances.each {|pp| pp.shift_dates(date_diff)}
      #shift all dataElements
      self.dataElements.each do |de|
        de.expiredDatetime = (de.expiredDatetime.nil?) ? nil : de.expiredDatetime + date_diff if de.qdmStatus == 'patientCharacteristicExpired'
        de.authorDatetime =  (de.authorDatetime.nil?) ? nil : de.authorDatetime + date_diff
        de.prevalencePeriod.shift_dates(date_diff) if de.prevalencePeriod
        de.relevantPeriod.shift_dates(date_diff) if de.relevantPeriod
      end

    end
    #
    # private
    #
    # def self.provider_queries(provider_id, effective_date)
    #  {'$or' => [provider_query(provider_id, effective_date,effective_date), provider_query(provider_id, nil,effective_date), provider_query(provider_id, effective_date,nil)]}
    # end
    # def self.provider_query(provider_id, start_before, end_after)
    #   {'provider_performances' => {'$elemMatch' => {'provider_id' => provider_id, '$and'=>[{'$or'=>[{'start_date'=>nil},{'start_date'=>{'$lt'=>start_before}}]}, {'$or'=>[{'end_date'=>nil},{'end_date'=> {'$gt'=>end_after}}]}] } }}
    # end

  end
end
