require 'cypress'
require 'health-data-standards'
require 'hqmf-parser'

Faker::Config.locale = 'en-US'

# sync default bundle with cypress.yml
Rails.application.configure do
  config.after_initialize do
    Bundle.each do |bundle|
      bundle.active = bundle.version == Cypress::AppConfig['default_bundle']
      bundle.save!
    end
  end
end
