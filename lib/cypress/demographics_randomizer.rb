Faker::Config.locale = 'en-US'
module Cypress
  # This is a set of helper methods to randomize demographic components of records.  Currently it
  # can randomize name, race, ethnicity, address, and insurance provider.  To randomize all
  # demographics, call Cypress::DemographicsRandomizer.randomize(record)
  class DemographicsRandomizer
    def self.randomize(record)
      randomize_name(record)
      randomize_race(record)
      randomize_ethnicity(record)
      randomize_address(record)
      randomize_insurance_provider(record)
    end

    def self.randomize_name(record)
      @used_names ||= {}
      @used_names[record.gender] ||= []
      loop do
        assign_random_name(record)
        break if @used_names[record.gender].index("#{record.first}-#{record.last}").nil?
      end
      @used_names[record.gender] << "#{record.first}-#{record.last}"
    end

    def self.assign_random_name(record)
      record.first = APP_CONFIG['randomization']['names']['first'][record.gender].sample
      record.last = APP_CONFIG['randomization']['names']['last'].sample
    end

    def self.randomize_race(record)
      record.race = APP_CONFIG['randomization']['races'].sample
    end

    def self.randomize_ethnicity(record)
      record.ethnicity = APP_CONFIG['randomization']['ethnicities'].sample
    end

    def self.randomize_address(record)
      address = Address.new
      address.use = 'HP'
      address.street = ["#{Faker::Address.street_address} #{Faker::Address.street_suffix}"]
      address.street.push(Faker::Address.secondary_address) if [true, false].sample
      address.city = Faker::Address.city
      address.state = Faker::Address.state_abbr
      address.zip = Faker::Address.zip(address.state)
      address.country = 'US'
      record.addresses = [address]
    end

    def self.randomize_insurance_provider(record)
      ip = InsuranceProvider.new
      randomize_payer(ip, record.birthdate)
      ip.financial_responsibility_type = { 'code' => 'SELF', 'codeSystem' => 'HL7 Relationship Code' }
      ip.member_id = Faker::Number.number(10)
      ip.start_time = get_random_payer_start_date(record)
      record.insurance_providers = [ip]
    end

    def self.randomize_payer(insurance_provider, birthdate)
      payer = APP_CONFIG['randomization']['payers'].sample
      # if the payer is Medicare and the patient is < 65 years old at the beginning of the measurement period, try again
      while payer['name'] == 'Medicare' && Time.at(birthdate).in_time_zone > Time.new(APP_CONFIG['effective_date']['year']).in_time_zone.years_ago(65)
        payer = APP_CONFIG['randomization']['payers'].sample
      end
      insurance_provider.codes = {}
      insurance_provider.codes[payer['codeSystem']] = []
      insurance_provider.codes[payer['codeSystem']] << payer['code'].to_s
      insurance_provider.name = payer['name']
      insurance_provider.type = payer['type']
      insurance_provider.payer = Organization.new(name: payer['name'])
    end

    def self.get_random_payer_start_date(record)
      start_times = record.entries.map { |entry| entry.time || entry.start_time }.compact
      random_offset = rand(60 * 60 * 24 * 365)
      if !start_times.empty?
        [start_times.min - random_offset, record.birthdate].max
      else
        record.birthdate
      end
    end
  end
end
