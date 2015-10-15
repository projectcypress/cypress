require 'simplecov'

SimpleCov.start 'rails'
SimpleCov.minimum_coverage 90

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/spec'
require 'minitest/autorun'

require 'minitest/reporters'
Minitest::Reporters.use!

include Warden::Test::Helpers
Warden.test_mode!

Mongoid.logger.level = Logger::INFO

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
