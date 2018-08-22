Faker::Config.locale = 'en-US'

Provider = QDM::Provider

module QDM
  class Provider
    has_many :measure_tests

    def self.default_provider(options = {})
      prov = where(default: true, specialty: default_specialty(options[:measure_type])).first
      if prov.nil?
        prov = Provider.new(APP_CONSTANTS['default_provider'])
        prov[:default] = true
        prov.specialty = default_specialty(options[:measure_type])
        prov.save
      end
      prov
    end

    def self.generate_provider(options = {})
      prov = Provider.new
      randomize_provider_address(prov)
      prov.given_name = NAMES_RANDOM['first'][%w[M F].sample].sample
      prov.family_name = NAMES_RANDOM['last'].sample
      prov.npi = NpiGenerator.generate
      prov.tin = rand.to_s[2..10]
      # rjust pads with 0s to the left of the number, so the CCN is always 6 digits
      prov.ccn = rand(1..66).to_s.rjust(2, '0') + rand(1..9899).to_s.rjust(4, '0')
      prov.specialty = default_specialty(options[:measure_type])
      prov.save!
      prov
    end

    def self.randomize_provider_address(provider)
      address = Address.new
      address.use = 'HP'
      address.street = ["#{Faker::Address.street_address} #{Faker::Address.street_suffix}"]
      address.city = Faker::Address.city
      address.state = Faker::Address.state_abbr
      address.zip = Faker::Address.zip(address.state)
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
