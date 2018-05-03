Faker::Config.locale = 'en-US'
module Cypress
  # This is a set of helper methods to randomize demographic components of records.  Currently it
  # can randomize name, race, ethnicity, address, and insurance provider.  To randomize all
  # demographics, call Cypress::DemographicsRandomizer.randomize(record)
  class DemographicsRandomizer
    def self.randomize(patient, prng, allow_dups = false)
      #TODO R2P: change to patient name and model throughout file
      randomize_name(patient, prng, allow_dups)
      # randomize_race(patient, prng) TODO R2P: priority 1.3
      # randomize_ethnicity(patient, prng)
      # randomize_address(patient)
      randomize_insurance_provider(patient)
    end

    #TODO: redundant with patient (formerly record) name randomization methods
    def self.randomize_name(patient, prng, allow_dups = false)
      gender = patient.gender
      @used_names ||= {}
      @used_names[gender] ||= []
      loop do
        assign_random_name(patient, prng)
        break if allow_dups || @used_names[gender].index("#{patient.first_names}-#{record.familyName}").nil?
      end
      @used_names[gender] << "#{patient.first_names}-#{patient.familyName}"
    end

    def self.assign_random_name(patient, prng)
      patient.givenNames.each_with_index do |i,name|{
        patient.givenNames[i] = NAMES_RANDOM['first'][patient.gender].sample(random: prng)
      }
      patient.familyName = NAMES_RANDOM['last'].sample(random: prng)
    end

    def self.randomize_race(patient, prng)
      record.race = APP_CONSTANTS['randomization']['races'].sample(random: prng)
    end

    def self.randomize_ethnicity(patient, prng)
      record.ethnicity = APP_CONSTANTS['randomization']['ethnicities'].sample(random: prng)
    end

    def self.randomize_address(patient)
      address = Address.new
      address.use = 'HP'
      address.street = ["#{Faker::Address.street_address} #{Faker::Address.street_suffix}"]
      address.city = Faker::Address.city
      address.state = Faker::Address.state_abbr
      address.zip = Faker::Address.zip(address.state)
      address.country = 'US'
      record.addresses = [address]
    end

    def self.randomize_insurance_provider(patient)
      ip = {}
      #TODO R2P: check should create nil keys for new insurance provider? and startTime format works?
      # patient.extendedData.insurance_providers[0].each_key{|k| ip[key]=nil}
      randomize_payer(ip, patient)
      ip.financial_responsibility_type = { 'code' => 'SELF', 'codeSystem' => 'HL7 Relationship Code' }
      ip.member_id = Faker::Number.number(10)
      ip.start_time = get_random_payer_start_date(patient)
      patient.extendedData.insurance_providers = JSON.generate([ip])
    end

    def self.randomize_payer(insurance_provider, patient)
      payer = APP_CONSTANTS['randomization']['payers'].sample
      # if the payer is Medicare and the patient is < 65 years old at the beginning of the measurement period, try again
      while payer['name'] == 'Medicare' &&
            Time.at(patient.birthDatetime).in_time_zone > Time.at(patient.bundle.effective_date).in_time_zone.years_ago(65)
        payer = APP_CONSTANTS['randomization']['payers'].sample
      end
      insurance_provider.codes = {}
      insurance_provider.codes[payer['codeSystem']] = []
      insurance_provider.codes[payer['codeSystem']] << payer['code'].to_s
      insurance_provider.name = payer['name']
      insurance_provider.type = payer['type']
      insurance_provider.payer = {"name"=> payer['name']}
    end

    def self.get_random_payer_start_date(patient)
      start_times = patient.dataElements.map { |de| de.authorDatetime }.compact
      random_offset = rand(60 * 60 * 24 * 365)
      if !start_times.empty?
        [start_times.min - random_offset, patient.birthDatetime].max
      else
        patient.birthDatetime
      end
    end
  end
end
