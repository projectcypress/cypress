Faker::Config.locale = 'en-US'
module Cypress
  # This is a set of helper methods to randomize demographic components of records.  Currently it
  # can randomize name, race, ethnicity, address, and insurance provider.  To randomize all
  # demographics, call Cypress::DemographicsRandomizer.randomize(record)
  class DemographicsRandomizer
    def self.randomize(patient, prng, allow_dups = false)
      # TODO: R2P: change to patient name and model throughout file
      randomize_name(patient, prng, allow_dups)
      randomize_race(patient, prng)
      randomize_ethnicity(patient, prng)
      randomize_address(patient)
      randomize_payer(patient, prng)
    end

    # TODO: redundant with patient (formerly record) name randomization methods
    def self.randomize_name(patient, prng, allow_dups = false)
      gender = patient.gender
      @used_names ||= {}
      @used_names[gender] ||= []
      loop do
        assign_random_name(patient, prng)
        break if allow_dups || @used_names[gender].index("#{patient.first_names}-#{patient.familyName}").nil?
      end
      @used_names[gender] << "#{patient.first_names}-#{patient.familyName}"
    end

    def self.assign_random_name(patient, prng)
      patient.givenNames.each_with_index { |_name, i| patient.givenNames[i] = NAMES_RANDOM['first'][patient.gender].sample(random: prng) }
      patient.familyName = NAMES_RANDOM['last'].sample(random: prng)
    end

    def self.randomize_gender(patient, prng)
      rand_gender = %w[M F].sample(random: prng)
      gender_chars = patient.qdmPatient.get_data_elements('patient_characteristic', 'gender')
      if gender_chars&.any? && gender_chars.first.dataElementCodes &&
         gender_chars.first.dataElementCodes.any?
        new_gender = gender_chars.first.dataElementCodes.first
        new_gender['code'] = rand_gender
        new_gender['descriptor'] = rand_gender
        gender_chars.first.dataElementCodes << new_gender
        gender_chars.first.dataElementCodes.shift
      else
        raise 'Cannot find gender element'
      end
    end

    def self.randomize_race(patient, prng)
      race_element = patient.qdmPatient.get_data_elements('patient_characteristic', 'race')
      race_hash = APP_CONSTANTS['randomization']['races'].sample(random: prng)
      if race_element&.any? && race_element.first.dataElementCodes &&
         race_element.first.dataElementCodes.any?
        new_race = race_element.first.dataElementCodes.first
        new_race['code'] = race_hash['code']
        new_race['codeSystemOid'] = race_hash['codeSystem']
        new_race['codeSystem'] = race_hash['codeSystemName']
        new_race['descriptor'] = race_hash['name']
        race_element.first.dataElementCodes << new_race
        race_element.first.dataElementCodes.shift # get rid of existing dataElementCode
      else
        raise 'Cannot find race element'
      end
    end

    def self.randomize_ethnicity(patient, prng)
      ethnicity_element = patient.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity')
      ethnicity_hash = APP_CONSTANTS['randomization']['ethnicities'].sample(random: prng)
      if ethnicity_element&.any? && ethnicity_element.first.dataElementCodes &&
         ethnicity_element.first.dataElementCodes.any?
        new_ethnicity = ethnicity_element.first.dataElementCodes.first
        new_ethnicity['code'] = ethnicity_hash['code']
        new_ethnicity['codeSystemOid'] = ethnicity_hash['codeSystem']
        new_ethnicity['codeSystem'] = ethnicity_hash['codeSystemName']
        new_ethnicity['descriptor'] = ethnicity_hash ['name']
        ethnicity_element.first.dataElementCodes << new_ethnicity
        ethnicity_element.first.dataElementCodes.shift # get rid of existing dataElementCode
      else
        raise 'Cannot find ethnicity element'
      end
    end

    def self.randomize_address(patient)
      address = {}
      address['use'] = 'HP'
      address['street'] = ["#{Faker::Address.street_address} #{Faker::Address.street_suffix}"]
      address['city'] = Faker::Address.city
      address['state'] = Faker::Address.state_abbr
      address['zip'] = Faker::Address.zip(address['state'])
      address['country'] = 'US'
      patient.addresses = [address]
    end

    def self.randomize_payer(patient, prng)
      payer_element = patient.qdmPatient.get_data_elements('patient_characteristic', 'payer')
      payer_hash = sample_payer(patient, prng)
      if payer_element&.any? && payer_element.first.dataElementCodes &&
         payer_element.first.dataElementCodes.any?
        new_payer = payer_element.first.dataElementCodes.first
        new_payer['code'] = payer_hash['code']
        new_payer['codeSystemOid'] = payer_hash['codeSystem']
        new_payer['codeSystem'] = payer_hash['codeSystemName']
        new_payer['descriptor'] = payer_hash ['name']
        payer_element.first.dataElementCodes << new_payer
        payer_element.first.dataElementCodes.shift # get rid of existing dataElementCode
      else
        raise 'Cannot find payer element'
      end
    end

    def self.get_random_payer_start_date(patient)
      start_times = patient.qdmPatient.dataElements.map { |de| de.try(:authorDatetime) }.compact
      random_offset = rand(60 * 60 * 24 * 365)
      if !start_times.empty?
        [start_times.min - random_offset, patient.qdmPatient.birthDatetime].max
      else
        patient.qdmPatient.birthDatetime
      end
    end

    def self.randomize_birthdate(patient, random: Random.new)
      birth_datetime = patient.birthDatetime
      while birth_datetime == patient.birthDatetime
        patient.birthDatetime = patient.birthDatetime.change(
          case random.rand(3)
          when 0 then { day: 1, month: 1 }
          when 1 then { day: random.rand(28) + 1 }
          when 2 then { month: random.rand(12) + 1 }
          end
        )
      end
      if patient.dataElements.where(_type: QDM::PatientCharacteristicBirthdate).first
        patient.dataElements.where(_type: QDM::PatientCharacteristicBirthdate).first.birthDatetime = patient.birthDatetime
      end
    end

    private

    def sample_payer(patient, prng)
      payer_hash = APP_CONSTANTS['randomization']['payers'].sample(random: prng)
      while payer_hash['name'] == 'Medicare' &&
            Time.at(patient.qdmPatient.birthDatetime).in_time_zone > Time.at(patient.bundle.effective_date).in_time_zone.years_ago(65)
        payer_hash = APP_CONSTANTS['randomization']['payers'].sample
      end
      payer_hash
    end
  end
end
