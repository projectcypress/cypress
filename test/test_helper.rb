ENV["RAILS_ENV"] = "test"

require_relative "./simplecov"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  
  def collection_fixtures(collection, *id_attributes)
    Mongoid.database[collection].drop
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
      Mongoid.database[collection].save(fixture_json, :safe => true)
    end
  end

  #the above method doesnt work if you have ids in a subarray, like in patient_cache where patient_id is under the "values" sub array
  #this method will work for the patient_cache problem, though its hacky
  def collection_fixtures2(collection, subattr, *id_attributes)# the collection, the name of the subarray where the id_attributes are hiding, the id_attributes you need
      Mongoid.database[collection].drop
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

        Mongoid.database[collection].save(fixture_json, :safe => true)
      end
    end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
