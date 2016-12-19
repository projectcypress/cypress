class Provider
  has_many :measure_tests

  def self.default_provider(options = {})
    prov = where(default: true, specialty: default_specialty(options[:measure_type])).first
    if prov.nil?
      prov = Provider.new(Cypress::AppConfig['default_provider'])
      prov[:default] = true
      prov.specialty = default_specialty(options[:measure_type])
      prov.save
    end
    prov
  end

  def self.generate_provider(options = {})
    prov = Provider.new
    Cypress::DemographicsRandomizer.randomize_address(prov)
    prov.given_name = Cypress::AppConfig['randomization']['names']['first'][%w(M F).sample].sample
    prov.family_name = Cypress::AppConfig['randomization']['names']['last'].sample
    prov.npi = NpiGenerator.generate
    prov.tin = rand.to_s[2..10]
    prov.specialty = default_specialty(options[:measure_type])
    prov.save!
    prov
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
