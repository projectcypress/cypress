class Provider
  def self.default_provider
    prov = where(default: true).first
    if prov.nil?
      prov = Provider.new(APP_CONFIG['default_provider'])
      prov[:default] = true
      prov.save
    end
    prov
  end

  def self.generate_provider(options = {})
    prov = Provider.new
    Cypress::DemographicsRandomizer.randomize_address(prov)
    prov.given_name = APP_CONFIG['randomization']['names']['first'][%w(M F).sample].sample
    prov.family_name = APP_CONFIG['randomization']['names']['last'].sample
    prov.npi = NpiGenerator.generate
    prov.tin = rand.to_s[2..10]
    prov.specialty = case options[:measure_type]
                     when 'ep'
                       '207Q00000X' # (Allopathic & Osteopathic Physicians/Family Practice)
                     when 'eh'
                       '282N00000X' # (Hospitals/General Acute Care Hospital)
                     end
    prov.save!
    prov
  end
end
