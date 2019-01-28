# The Patient model is an extension of app/models/qdm/patient.rb as defined by CQM-Models.
Patient = CQM::Patient

module CQM
  class Patient
    has_many :calculation_results, foreign_key: :patient_id, class_name: 'CQM::IndividualResult'
    field :correlation_id, type: BSON::ObjectId
    field :original_patient_id, type: BSON::ObjectId
    field :insurance_providers, type: Array
    field :original_medical_record_number, type: String
    field :medical_record_number, type: String
    embeds_many :addresses

    def destroy
      calculation_results.destroy
      delete
    end

    def product_test
      ProductTest.where('_id' => correlation_id).most_recent
    end

    def bundle
      if !self['bundleId'].nil?
        Bundle.find(self['bundleId'])
      elsif !correlation_id.nil?
        ProductTest.find(correlation_id).bundle
      end
    end

    def age_at(date)
      dob = Time.at(qdmPatient.birthDatetime).in_time_zone
      date.year - dob.year - (date.month > dob.month || (date.month == dob.month && date.day >= dob.day) ? 0 : 1)
    end

    def original_patient
      Patient.find(original_patient_id) if original_patient_id
    end

    def lookup_provider(include_address = nil)
      # find with provider id hash i.e. "$oid"->value
      provider = Provider.find(provider_performances.first['provider_id'])
      addresses = []
      provider.addresses.each do |address|
        addresses << { 'street' => address.street, 'city' => address.city, 'state' => address.state, 'zip' => address.zip,
                       'country' => address.country }
      end

      return { 'npis' => [provider.npi], 'tins' => [provider.tin], 'addresses' => addresses } if include_address

      { 'npis' => [provider.npi], 'tins' => [provider.tin] }
    end

    def duplicate_randomization(random: Random.new)
      patient = clone
      changed = { original_patient_id: id, first: [first_names, first_names], last: [familyName, familyName] }
      patient, changed = randomize_patient_name_or_birth(patient, changed, random: random)
      randomize_demographics(patient, changed, random: random)
    end

    def provider
      return nil unless provider_performances

      Provider.find(provider_performances.first['provider_id'])
    end

    #
    # private
    #
    # TODO: R2P: use private keyword?
    def first_names
      givenNames.join(' ')
    end

    def randomize_patient_name_or_birth(patient, changed, random: Random.new)
      case random.rand(3) # random chooses which part of the patient is modified
      when 0 # first name
        patient = Cypress::NameRandomizer.randomize_patient_name_first(patient, random: random)
        changed[:first] = [first_names, patient.first_names]
      when 1 # last name
        patient = Cypress::NameRandomizer.randomize_patient_name_last(patient, random: random)
        changed[:last] = [familyName, patient.familyName]
      when 2 # birthdate
        Cypress::DemographicsRandomizer.randomize_birthdate(patient.qdmPatient, random: random)
        changed[:birthdate] = [qdmPatient.birthDatetime, patient.qdmPatient.birthDatetime]
      end
      [patient, changed]
    end

    def gender
      gender_chars = qdmPatient.get_data_elements('patient_characteristic', 'gender')
      if gender_chars&.any? && gender_chars.first.dataElementCodes &&
         gender_chars.first.dataElementCodes.any?
        gender_chars.first.dataElementCodes.first['code']
      else
        raise 'Cannot find gender element'
      end
    end

    def race
      race_element = qdmPatient.get_data_elements('patient_characteristic', 'race')
      if race_element&.any? && race_element.first.dataElementCodes &&
         race_element.first.dataElementCodes.any?
        race_element.first.dataElementCodes.first['code']
      else
        raise 'Cannot find race element'
      end
    end

    def ethnicity
      ethnicity_element = qdmPatient.get_data_elements('patient_characteristic', 'ethnicity')
      if ethnicity_element&.any? && ethnicity_element.first.dataElementCodes &&
         ethnicity_element.first.dataElementCodes.any?
        ethnicity_element.first.dataElementCodes.first['code']
      else
        raise 'Cannot find ethnicity element'
      end
    end

    def randomize_demographics(patient, changed, random: Random.new)
      case random.rand(3) # now, randomize demographics
      when 0 # gender
        Cypress::DemographicsRandomizer.randomize_gender(patient, random)
        changed[:gender] = [gender, patient.gender]
      when 1 # race
        Cypress::DemographicsRandomizer.randomize_race(patient, random)
        changed[:race] = [race, patient.race]
      when 2 # ethnicity
        Cypress::DemographicsRandomizer.randomize_ethnicity(patient, random)
        changed[:ethnicity] = [ethnicity, patient.ethnicity]
      end
      [patient, changed, self]
    end
    #
    # HDS helpers
    #
  end
end
