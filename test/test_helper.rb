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



class  MiniTest::Test
  
   def drop_database
    Mongoid.default_client.database.drop
   end

   def collection_fixtures(collection, *id_attributes)
    Mongoid.default_client[collection].drop
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
      fixture_json = JSON.parse(File.read(json_fixture_file), max_nesting: 250)
      id_attributes.each do |attr|

        if fixture_json[attr].nil?
          next
        end

        if fixture_json[attr].kind_of? Array
          fixture_json[attr] = fixture_json[attr].collect{|att| BSON::ObjectId.from_string(att)}
        else
          fixture_json[attr] = BSON::ObjectId.from_string(fixture_json[attr])
        end
      end

      if fixture_json["created_at"]
         fixture_json["created_at"] = Time.at(fixture_json["created_at"] )
      end
      Mongoid.default_client[collection].insert_one(fixture_json)
    end


     #the above method doesnt work if you have ids in a subarray, like in patient_cache where patient_id is under the "values" sub array
  #this method will work for the patient_cache problem, though its hacky
  def collection_fixtures2(collection, subattr, *id_attributes)# the collection, the name of the subarray where the id_attributes are hiding, the id_attributes you need
      Mongoid.default_client[collection].drop
      Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
        fixture_json = JSON.parse(File.read(json_fixture_file))
        id_attributes.each do |attr|

          if fixture_json[attr].nil?
            next
          end

          if fixture_json[attr].kind_of? Array
            fixture_json[attr] = fixture_json[attr].collect{|att| BSON::ObjectId.from_string(att)}
          else
            fixture_json[attr] = BSON::ObjectId.from_string(fixture_json[attr])
          end
        end

        id_attributes.each do |attr|

          if fixture_json[subattr][attr].nil?
            next
          end

          if fixture_json[subattr][attr].kind_of? Array
            fixture_json[subattr][attr] = fixture_json[subattr][attr].collect{|att| BSON::ObjectId.from_string(att)}
          else
            fixture_json[subattr][attr] = BSON::ObjectId.from_string(fixture_json[subattr][attr])
          end
        end

        Mongoid.default_client[collection].insert_one(fixture_json)
      end
    end


  end

 # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end
