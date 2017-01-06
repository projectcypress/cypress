require 'cypress'
require 'health-data-standards'
require 'hqmf-parser'

Faker::Config.locale = 'en-US'

Rails.application.configure do
  config.after_initialize do
    Cypress::AppConfig.refresh

    # sync default bundle with cypress.yml
    Bundle.each do |bundle|
      bundle.active = bundle.version == Cypress::AppConfig['default_bundle']
      bundle.save!
    end
  end
end
