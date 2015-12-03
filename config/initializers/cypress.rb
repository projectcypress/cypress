require 'cypress'
require 'health-data-standards'
require 'hqmf-parser'

Faker::Config.locale = 'en-US'

if Provider.where(default: true).first.nil?
  prov = Provider.new(APP_CONFIG[:default_provider])
  prov[:default]=true
  prov.save
end
