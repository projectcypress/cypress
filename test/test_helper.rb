require 'simplecov'

SimpleCov.start 'rails'
SimpleCov.minimum_coverage 90

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/setup'

Minitest::Reporters.use!

include Warden::Test::Helpers
Warden.test_mode!

Mongoid.logger.level = Logger::INFO
Mongo::Logger.logger.level = Logger::WARN
class MiniTest::Test
  def create_rack_test_file(filename, type)
    Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, filename)), type)
  end

  def drop_database
    Mongoid.default_client.database.drop
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

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
