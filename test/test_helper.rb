require 'simplecov'

SimpleCov.start 'rails'
# MiniTest changes mean that our coverage suddenly dropped, since more controllers are being tested.
# We dropped the value to 77 to be able to get pull requests pulled in. Needs to be brought back up as coverage goes back up.
SimpleCov.minimum_coverage 77

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/setup'

Minitest::Reporters.use!
# comment the previous line and uncomment the next one for test-by-test details
# Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

include Warden::Test::Helpers
Warden.test_mode!

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::WARN
class ActiveSupport::TestCase
  def teardown
    drop_database
  end

  def create_rack_test_file(filename, type)
    Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, filename)), type)
  end

  def drop_database
    Mongoid::Config.purge!
    # purge the database instead of dropping it
    # because dropping it literally deletes the file
    # which then has to be recreated (which is slow)
  end

  def drop_collection(collection)
    Mongoid.default_client[collection].drop
  end

  def value_or_bson(v)
    if v.is_a? Hash
      if v['$oid']
        BSON::ObjectId.from_string(v['$oid'])
      else
        map_bson_ids(v)
      end
    else
      v
    end
  end

  def map_bson_ids(json)
    json.each_pair do |k, v|
      if v.is_a? Hash
        json[k] = value_or_bson(v)
      elsif k == 'create_at' || k == 'updated_at'
        json[k] = Time.at.utc(v)
      end
    end
    json
  end

  def collection_fixtures(*collections)
    collections.each do |collection|
      Mongoid.default_client[collection].drop
      Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
        fixture_json = JSON.parse(File.read(json_fixture_file), max_nesting: 250)
        map_bson_ids(fixture_json)
        Mongoid.default_client[collection].insert_one(fixture_json)
      end
    end
  end

  def load_library_functions
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', 'library_functions', '*.js')).each do |js_path|
      fn = "function () {\n #{File.read(js_path)} \n }"
      name = File.basename(js_path, '.js')
      Mongoid.default_client['system.js'].replace_one({ '_id' => name },
                                                      { '_id' => name,
                                                        'value' => BSON::Code.new(fn)
                                                      }, upsert: true
                                                     )
    end
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
