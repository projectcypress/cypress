class InpatientProductTestTest < ActiveSupport::TestCase

  setup do
    
    collection_fixtures('bundles','_id')
    collection_fixtures('measures','_id','bundle_id')
    collection_fixtures('query_cache', '_id', 'bundle_id')
    collection_fixtures('records', '_id', 'bundle_id')
  end

  test "should be able to retrieve eh measures for test creation" do 

    measures = InpatientProductTest.product_type_measures(Bundle.active.first)
    assert_equal 4, measures.count, "Measure count incorrect"
    types = measures.collect{|m| m.type}.uniq
    assert_equal 1, types.length , "There should only be one unique type entry"
    assert_equal "eh", types[0], "Measure type should be eh"
    
  end

  
end