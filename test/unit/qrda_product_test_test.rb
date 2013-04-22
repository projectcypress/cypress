require 'test_helper'

class QRDAProductTestTest < ActiveSupport::TestCase
  setup do
    dump_database

    collection_fixtures('measures','bundle_id')
    collection_fixtures('bundles','_id')
    collection_fixtures('records','_id', "bundle_id")
    collection_fixtures('patient_cache','_id','bundle_id') 
    collection_fixtures('product_tests', '_id','bundle_id')
    
    @test = QRDAProductTest.find("509144aa709357a906000018")
  end
  
  test "Should generate a population" do
    assert_nil Record.where(test_id: @test).first

    total_records = Record.all.size
    @test.generate_population
    assert [total_records+4,total_records+3].index(Record.all.size), "Should have created 3 or 4 records depending on which denom/exclusions are picked at random"

    assert_not_nil Record.where(test_id: @test).first
  end
end