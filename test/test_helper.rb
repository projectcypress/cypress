ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  
  def collection_fixtures(collection, *id_attributes)
    Mongoid.database[collection].drop
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
      fixture_json = JSON.parse(File.read(json_fixture_file))
      id_attributes.each do |attr|
        
        if fixture_json[attr].kind_of? Array
          fixture_json[attr] = fixture_json[attr].collect{|att| BSON::ObjectId.from_string(att)}
        else
        fixture_json[attr] = BSON::ObjectId.from_string(fixture_json[attr])
        end
      end
      Mongoid.database[collection].save(fixture_json, :safe => true)
    end
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
