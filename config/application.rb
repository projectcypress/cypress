# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
require 'rails/test_unit/railtie'

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

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join('lib')
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # prevent rails from wrapping inputs with errors in a div of class "field_with_errors"
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }
    config.active_job.queue_adapter = :delayed_job

    # This lets us define our own routes for error pages
    config.exceptions_app = routes
  end
end
