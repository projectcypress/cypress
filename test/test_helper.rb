ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  
  def collection_fixtures(collection, *id_attributes)
    MONGO_DB[collection].drop
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
      #puts "Loading #{json_fixture_file}"
      fixture_json = JSON.parse(File.read(json_fixture_file))
      id_attributes.each do |attr|
        fixture_json[attr] = BSON::ObjectId.from_string(fixture_json[attr])
      end
      MONGO_DB[collection].save(fixture_json)
    end
  end
end
