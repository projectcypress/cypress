# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'
require_relative '../lib/hash'

CAT1_CONFIG = YAML.safe_load(File.read(File.expand_path('cat1checklist.yml', __dir__)), [], [], true)
CMS_IG_CONFIG = YAML.safe_load(File.read(File.expand_path('cms_ig.yml', __dir__)), [], [], true)
APP_CONSTANTS = YAML.safe_load(ERB.new(File.read(File.expand_path('cypress.yml', __dir__))).result, [], [], true)
NAMES_RANDOM = YAML.safe_load(File.read(File.expand_path('names.yml', __dir__)), [], [], true)
TEST_ATTRIBUTES = YAML.safe_load(File.read(File.expand_path('testing_attributes.yml', __dir__)), [], [], true)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cypress
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    config.eager_load_paths << Rails.root.join('lib')
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # prevent rails from wrapping inputs with errors in a div of class "field_with_errors"
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }
    config.active_job.queue_adapter = :delayed_job

    # This lets us define our own routes for error pages
    config.exceptions_app = routes
  end
end
