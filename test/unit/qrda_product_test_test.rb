require 'test_helper'

class QRDAProductTestTest < ActiveSupport::TestCase
  setup do
    dump_database

    collection_fixtures('measures')
    collection_fixtures('product_tests', '_id')
    
    @test = ProductTest.find("509144aa709357a906000018")
  end
  
  test "Should generate a population" do
    assert_nil Record.where(test_id: @test).first

    total_records = Record.all.size
    @test.generate_population
    
    assert_equal total_records + 1, Record.all.size
    assert_not_nil Record.where(test_id: @test).first
  end
end