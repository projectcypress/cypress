# frozen_string_literal: true

Faker::Config.locale = 'en-US'
module Cypress
  # This is a set of helper methods to randomize demographic components of records.  Currently it
  # can randomize name, race, ethnicity, address, and insurance provider.  To randomize all
  # demographics, call Cypress::DemographicsRandomizer.randomize(record)
  class DemographicsRandomizer
    def self.randomize(patient, prng, patients = [], allow_dups: false)
      randomize_name(patient, prng, patients, allow_dups:)
      randomize_race(patient, prng)
      randomize_ethnicity(patient, prng)
      randomize_address(patient)
      randomize_payer(patient, prng)
    end

    # Pass in an array of patients that you would like to maintain uniqueness
    def self.randomize_name(patient, prng, patients = [], allow_dups: false)
      used_names = patients.map { |p| "#{p.first_names}-#{p.familyName}" }
      loop_index = 0
      loop do
        assign_random_name(patient, prng)
        break if allow_dups || used_names.index("#{patient.first_names}-#{patient.familyName}").nil?

        loop_index += 1
        # This is extremely unlikely, but provide an out of 100 tries does not create a unique name
        break if loop_index == 100
      end
      patient.email = create_email(patient, true)
    end

    def self.assign_random_name(patient, prng)
      gender_code = %w[M 248153007].include?(patient.gender) ? 'M' : 'F'
      patient.givenNames.each_with_index { |_name, i| patient.givenNames[i] = NAMES_RANDOM['first'][gender_code].sample(random: prng) }
      patient.familyName = NAMES_RANDOM['last'].sample(random: prng)
    end

    def self.randomize_gender(patient, prng)
      rand_gender = patient.bundle.randomization['genders'].sample(random: prng)
      gender_chars = patient.qdmPatient.get_data_elements('patient_characteristic', 'gender')
      raise 'Cannot find gender element' unless gender_chars&.any? && gender_chars.first.dataElementCodes&.any?

      new_gender = gender_chars.first.dataElementCodes.first
      new_gender['code'] = rand_gender
      new_gender['descriptor'] = rand_gender
      gender_chars.first.dataElementCodes << new_gender
      gender_chars.first.dataElementCodes.shift
    end

    def self.randomize_race(patient, prng)
      race_element = patient.qdmPatient.get_data_elements('patient_characteristic', 'race')
      race_hash = patient.bundle.randomization['races'].sample(random: prng)
      raise 'Cannot find race element' unless race_element&.any? && race_element.first.dataElementCodes&.any?

      new_race = race_element.first.dataElementCodes.first
      new_race['code'] = race_hash['code']
      new_race['system'] = race_hash['codeSystem']
      new_race['codeSystem'] = race_hash['codeSystemName']
      new_race['descriptor'] = race_hash['name']
      race_element.first.dataElementCodes << new_race
      race_element.first.dataElementCodes.shift # get rid of existing dataElementCode
    end

    def self.randomize_ethnicity(patient, prng)
      ethnicity_element = patient.qdmPatient.get_data_elements('patient_characteristic', 'ethnicity')
      ethnicity_hash = patient.bundle.randomization['ethnicities'].sample(random: prng)
      raise 'Cannot find ethnicity element' unless ethnicity_element&.any? && ethnicity_element.first.dataElementCodes&.any?

      new_ethnicity = ethnicity_element.first.dataElementCodes.first
      new_ethnicity['code'] = ethnicity_hash['code']
      new_ethnicity['system'] = ethnicity_hash['codeSystem']
      new_ethnicity['codeSystem'] = ethnicity_hash['codeSystemName']
      new_ethnicity['descriptor'] = ethnicity_hash['name']
      ethnicity_element.first.dataElementCodes << new_ethnicity
      ethnicity_element.first.dataElementCodes.shift # get rid of existing dataElementCode
    end

    def self.randomize_address(patient)
      patient.addresses = create_address
      # creates a random address for provider
      # patient.providers = [CQM::Provider.generate_provider] # could maybe use 'ep'/'eh' measure option?
      patient.telecoms = create_telecom
    end

    def self.create_address
      state = Faker::Address.state_abbr
      address = CQM::Address.new(
        use: 'HP',
        street: ["#{Faker::Address.street_address} #{Faker::Address.street_suffix}"],
        city: Faker::Address.city,
        state:,
        zip: Faker::Address.zip_code(state_abbreviation: state),
        country: 'US'
      )
      [address]
    end

    def self.create_telecom
      telecom = CQM::Telecom.new(
        use: 'HP',
        value: us_number.gsub(/\s+/, '')
      )
      [telecom]
    end

    # A method that makes sure we provide a phone number using a valid US area code
    def self.us_number
      loop do
        phone_number = Faker::PhoneNumber.cell_phone
        return phone_number if TelephoneNumber.parse(phone_number, :us).valid?
      end
    end

    def self.create_email(patient, randomize)
      # When randomize is false, the email will always be {FirstName}{LastName}1@example.com
      # When randomize is true, the email will always be {FirstInitial}{LastName}{xxxxx}@example.com
      user_number = randomize ? rand(10_000) : 1
      user_first = randomize ? patient.first_names[0] : patient.first_names.delete(" \t\r\n")
      patient.email = "#{user_first}#{patient.familyName.delete(" \t\r\n")}#{user_number}@example.com".downcase
    end

    def self.randomize_payer(patient, prng)
      payer_element = patient.qdmPatient.get_data_elements('patient_characteristic', 'payer')
      payer_hash = sample_payer(patient, prng)
      raise 'Cannot find payer element' unless payer_element&.any? && payer_element.first.dataElementCodes&.any?

      new_payer = payer_element.first.dataElementCodes.first
      new_payer['code'] = payer_hash['code'].to_s
      new_payer['system'] = payer_hash['codeSystem']
      new_payer['codeSystem'] = payer_hash['codeSystemName']
      new_payer['descriptor'] = payer_hash['name']
      payer_element.first.dataElementCodes << new_payer
      payer_element.first.dataElementCodes.shift # get rid of existing dataElementCode
      payer_element.first.relevantPeriod = QDM::Interval.new(get_random_payer_start_date(patient, new_payer['code'] == '1', prng), nil)
      patient.medicare_beneficiary_identifier = new_payer['code'] == '1' ? Cypress::MbiGenerator.generate : nil
    end

    def self.get_random_payer_start_date(patient, is_medicare, prng)
      start_times = patient.qdmPatient.dataElements.map { |de| de.try(:authorDatetime) }.compact
      # Offset is a random date within December of prior year
      random_offset = prng.rand(31)
      # If medicare, start coverage at 65th birthdate
      if is_medicare
        start_time = patient.qdmPatient.birthDatetime
        start_time.change(year: patient.qdmPatient.birthDatetime.year + 65, day: 1)
      elsif start_times.empty?
        patient.qdmPatient.birthDatetime
      else
        [DateTime.new(start_times.min.year, 1, 1) - random_offset, patient.qdmPatient.birthDatetime].max
      end
    end

    def self.randomize_birthdate(patient, random: Random.new)
      birth_datetime = patient.birthDatetime
      days_in_month = Time.days_in_month(patient.birthDatetime.month, patient.birthDatetime.year)
      patient.birthDatetime = patient.birthDatetime.change(day: random.rand(days_in_month) + 1) while birth_datetime == patient.birthDatetime
      return unless patient.dataElements.where(_type: QDM::PatientCharacteristicBirthdate).first

      patient.dataElements.where(_type: QDM::PatientCharacteristicBirthdate).first.birthDatetime = patient.birthDatetime
    end

    def self.sample_payer(patient, prng)
      exportable_payer = patient.bundle.randomization['payers'].select { |payer| payer['useInExport'] == true }
      payer_hash = exportable_payer.sample(random: prng)
      # Some measures need Medicare patients, inflate the probability by trying again if one isn't found the first time
      payer_hash = exportable_payer.sample(random: prng) unless payer_hash['name'] == 'Medicare'
      while payer_hash['name'] == 'Medicare' &&
            Time.at(patient.qdmPatient.birthDatetime).in_time_zone > Time.at(patient.bundle.effective_date).in_time_zone.years_ago(65)
        payer_hash = exportable_payer.sample
      end
      payer_hash
    end

    # work around for null gender | race | ethnicity
    def self.assign_default_demographics(patient, randomize: false)
      elements = []
      unless patient&.gender
        default_gender = patient.bundle.randomization['genders'].first
        elements << QDM::PatientCharacteristicSex.new(dataElementCodes: [{ 'code' => default_gender.code,
                                                                           'system' => default_gender.codeSystem }])
      end
      unless patient&.race
        elements << QDM::PatientCharacteristicRace.new(dataElementCodes: [{ 'code' => '2028-9', 'system' => '2.16.840.1.113883.6.238' }])
      end
      unless patient&.ethnicity
        elements << QDM::PatientCharacteristicEthnicity.new(dataElementCodes: [{ 'code' => '2186-5', 'system' => '2.16.840.1.113883.6.238' }])
      end
      unless patient&.payer
        elements << QDM::PatientCharacteristicPayer.new(dataElementCodes: [{ 'code' => '1', 'system' => '2.16.840.1.113883.3.221.5' }],
                                                        relevantPeriod: QDM::Interval.new(patient.qdmPatient.birthDatetime, nil))
      end
      patient.medicare_beneficiary_identifier = Cypress::MbiGenerator.generate if patient.payer == '1'
      patient.email = create_email(patient, randomize) unless patient.email
      patient.qdmPatient.dataElements.concat(elements)
    end

    def self.update_demographic_codes(patient)
      randomization_mapping = { 'race' => 'races', 'gender' => 'genders', 'ethnicity' => 'ethnicities', 'payer' => 'payers' }
      %w[race gender ethnicity payer].each do |characteristic|
        patient.qdmPatient.get_data_elements('patient_characteristic', characteristic).first.dataElementCodes.each do |dec|
          description = patient.bundle.randomization[randomization_mapping[characteristic]].select { |r| r.code.to_s == dec.code }&.first&.name
          patient.code_description_hash["#{dec.code}:#{dec.system}".tr('.', '_')] = description
        end
      end
    end
  end
end
