# frozen_string_literal: true

Faker::Config.locale = 'en-US'

Provider = CQM::Provider

module CQM
  class Provider
    has_many :measure_tests

    def self.default_provider(options = {})
      prov = where(default: true, specialty: default_specialty(options[:measure_type])).first
      if prov.nil?
        prov = CQM::Provider.new(APP_CONSTANTS['default_provider'])
        prov[:default] = true
        prov.specialty = default_specialty(options[:measure_type])
        prov.save
        # TODO: This seems wrong
        npi = APP_CONSTANTS['default_provider_ids'].select { |dpi| dpi.namingSystem == '2.16.840.1.113883.4.6' }.first.value
        tin = APP_CONSTANTS['default_provider_ids'].select { |dpi| dpi.namingSystem == '2.16.840.1.113883.4.2' }.first.value
        prov.ids.build(namingSystem: '2.16.840.1.113883.4.6', value: npi)
        prov.ids.build(namingSystem: '2.16.840.1.113883.4.2', value: tin)
        prov.save
      end
      prov
    end

    # rubocop:disable Metrics/AbcSize
    def self.generate_provider(options = {})
      prov = CQM::Provider.new
      randomize_provider_address(prov)
      prov.givenNames = [NAMES_RANDOM['first'][%w[M F].sample].sample]
      prov.familyName = NAMES_RANDOM['last'].sample
      prov.specialty = default_specialty(options[:measure_type])
      prov.save!
      ccn = options[:preferred_ccn] || prov.ccn = rand(1..66).to_s.rjust(2, '0') + rand(1..9899).to_s.rjust(4, '0')
      # TODO: This seems wrong
      prov.ids.build(namingSystem: '2.16.840.1.113883.4.6', value: NpiGenerator.generate)
      prov.ids.build(namingSystem: '2.16.840.1.113883.4.2', value: rand.to_s[2..10])
      prov.ids.build(namingSystem: '2.16.840.1.113883.4.336', value: ccn)
      prov.save!
      prov
    end
    # rubocop:enable Metrics/AbcSize

    def self.randomize_provider_address(provider)
      address = CQM::Address.new
      address.use = 'HP'
      address.street = ["#{Faker::Address.street_address} #{Faker::Address.street_suffix}"]
      address.city = Faker::Address.city
      address.state = Faker::Address.state_abbr
      address.zip = Faker::Address.zip_code(state_abbreviation: address.state)
      address.country = 'US'
      provider.addresses = [address]
    end

    def self.default_specialty(measure_type)
      case measure_type
      when 'ep'
        '207Q00000X' # (Allopathic & Osteopathic Physicians/Family Practice)
      when 'eh'
        '282N00000X' # (Hospitals/General Acute Care Hospital)
      end
    end
  end
end
