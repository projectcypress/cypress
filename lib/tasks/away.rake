require 'quality-measure-engine'
require 'pry'

loader = QME::Database::Loader.new()

namespace :away do
  desc 'Drop all collections in the DB, excluding system.*'
  task :everything  => :environment do
    loader.get_db.collections.each do |collection|
      if collection.name != 'system.indexes' && collection.name != 'system.js'
        loader.drop
      end
    end
  end
  
  desc 'Drop the collections specific to the Cypress workflow'
  task :cypress  => :environment do
    loader.drop_collection('products')
    loader.drop_collection('product_tests')
    loader.drop_collection('test_executions')
    loader.drop_collection('vendors')
  end
  
  desc 'Drop the collections related to records and measure calculation'
  task :shared => :environment do
    loader.drop_collection('bundles')
    loader.drop_collection('measures')
    loader.drop_collection('races')
    loader.drop_collection('ethnicities')
    loader.drop_collection('languages')
    loader.drop_collection('records')
    loader.drop_collection('patient_cache')
    loader.drop_collection('patient_populations')
    loader.drop_collection('query_cache')
  end
end