ENV["RAILS_ENV"] = "test"

require_relative "./simplecov"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha'

require 'active_support/testing/pending'







class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  
  def load_code_sets
    MONGO_DB['races'].drop() if MONGO_DB['races']
    MONGO_DB['ethnicities'].drop() if MONGO_DB['ethnicities']
   JSON.parse(File.read(File.join(Rails.root, 'test', 'fixtures', 'code_sets', 'races.json'))).each do |document|
      MONGO_DB['races'].insert(document)
    end
    JSON.parse(File.read(File.join(Rails.root, 'test', 'fixtures', 'code_sets', 'ethnicities.json'))).each do |document|
      MONGO_DB['ethnicities'].insert(document)
    end
  end

 
  def collection_fixtures(collection, *id_attributes)
    Mongoid.session(:default)[collection].drop
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
      fixture_json = JSON.parse(File.read(json_fixture_file), max_nesting: 250)
      id_attributes.each do |attr|
        
        if fixture_json[attr].nil?
          next
        end

        if fixture_json[attr].kind_of? Array
          fixture_json[attr] = fixture_json[attr].collect{|att| Moped::BSON::ObjectId(att)}
        else
          fixture_json[attr] = Moped::BSON::ObjectId(fixture_json[attr])
        end
      end

      if fixture_json["created_at"] 
         fixture_json["created_at"] = Time.at(fixture_json["created_at"] )
      end
      Mongoid.default_session[collection].insert(fixture_json)
    end
  end

  #the above method doesnt work if you have ids in a subarray, like in patient_cache where patient_id is under the "values" sub array
  #this method will work for the patient_cache problem, though its hacky
  def collection_fixtures2(collection, subattr, *id_attributes)# the collection, the name of the subarray where the id_attributes are hiding, the id_attributes you need
      Mongoid.session(:default)[collection].drop
      Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
        fixture_json = JSON.parse(File.read(json_fixture_file))
        id_attributes.each do |attr|
          
          if fixture_json[attr].nil?
            next
          end

          if fixture_json[attr].kind_of? Array
            fixture_json[attr] = fixture_json[attr].collect{|att| Moped::BSON::ObjectId(att)}
          else
            fixture_json[attr] = Moped::BSON::ObjectId(fixture_json[attr])
          end
        end

        id_attributes.each do |attr|
          
          if fixture_json[subattr][attr].nil?
            next
          end

          if fixture_json[subattr][attr].kind_of? Array
            fixture_json[subattr][attr] = fixture_json[subattr][attr].collect{|att| Moped::BSON::ObjectId(att)}
          else
            fixture_json[subattr][attr] = Moped::BSON::ObjectId(fixture_json[subattr][attr])
          end
        end

        Mongoid.default_session[collection].insert(fixture_json)
      end
    end

  def wipe_db_and_load_patients()
    Mongoid.default_session['records'].drop
    Mongoid.default_session['measures'].drop
    Mongoid.default_session['query_cache'].drop
    Mongoid.default_session['patient_cache'].drop

    loader = QME::Database::Loader.new('cypress_test')
    mpl_version = ENV["mpl_version"] || APP_CONFIG["mpl_version"]
    mpl_dir  = File.join(Rails.root, "db", "mpl")
    mpl_file = File.join(mpl_dir, "bundle_#{mpl_version}.zip")
    mpl_file = open(mpl_file)
    Cypress::PatientImporter.new(loader.get_db).import(mpl_file)

    Record.count
  end
  
  def load_measures
    importer = Measures::Importer.new(MONGO_DB)
    importer.drop_measures()
    importer.import(File.new(File.join(Rails.root, "db", "measures", "bundle_#{APP_CONFIG["measures_version"]}.zip")))
  end
  
   def dump_database
   Mongoid.session(:default).collections.each do |collection|
      collection.drop unless collection.name.include?('system.') 
    end
 end

end

class ActionController::TestCase
  include Devise::TestHelpers
end
