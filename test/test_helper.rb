ENV["RAILS_ENV"] = "test"

require_relative "./simplecov"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'
require 'measures/importer'

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
  def wipe_db_and_load_patients()
    Mongoid.database['records'].drop
    Mongoid.database['measures'].drop
    Mongoid.database['query_cache'].drop
    Mongoid.database['patient_cache'].drop
    patient_count = 0
    loader = QME::Database::Loader.new('cypress_test')
    mpl_dir = File.join(Rails.root, 'db', 'master_patient_list')
    mpls = File.join(mpl_dir, '*')
    Dir.glob(mpls) do |patient_file|
      json = JSON.parse(File.read(patient_file))
      if json['_id']
        json['_id'] = BSON::ObjectId.from_string(json['_id'])
      end
      loader.save('records', json)
      patient_count = patient_count + 1
    end
    
    patient_count
  end
  
  def load_measures
    importer = Measures::Importer.new(Mongoid.master)
    importer.drop_measures()
    importer.import(File.new("./db/bundle.zip"))
  end
  
  
end

class ActionController::TestCase
  include Devise::TestHelpers
end
