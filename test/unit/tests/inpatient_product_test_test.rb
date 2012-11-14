class InpatientProductTestTest < ActiveSupport::TestCase

  setup do
    
    collection_fixtures('measures', '_id')
    collection_fixtures('query_cache', '_id')
    collection_fixtures('records', '_id')
  end


  test "should be able to retrieve eh measures for test creation" do 
    measures = InpatientProductTest.product_type_measures
    assert_equal 3, measures.count, "Measure count incorrect"
    types = measures.collect{|m| m.type}.uniq
    assert_equal 1, types.length , "There should only be one unique type entry"
    assert_equal "eh", types[0], "Measure type should be eh"
    
  end
  

  test "should be able to create and execute a test" do
  	measure_ids = ["8A4D92B2-3887-5DF3-0139-0D01C6626E46","8A4D92B2-3887-5DF3-0139-0D08A4BE7BE6"]
  	pt = InpatientProductTest.new(measure_ids: measure_ids, name:"In Test", effective_date: Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE)
  	pt.save

  	
  	assert_equal "ready", pt.state, "Test should be in a ready state"
  	assert_equal measure_ids, pt.measures.collect{|m| m.hqmf_id}, "Test should have the same measure_ids created with"
    assert pt.expected_results, "Test should have expected results"

    measure_ids.each do |mid|
    	assert pt.expected_results[mid], "Test should contain an expected results for #{mid}"
    end

    assert_equal 3, pt.records.count , "Test should have the correct number of patient records"
        
  end





  test "should set state to errored when there was a problem creating the test" do
    
  end
  
  
#   test "execute qrda" do
# #    binding.pry
#     pt1 = ProductTest.find("4f58f8de1d41c851eb000999")
#     ex_count = TestExecution.where(:product_test_id => pt1.id).count

#     qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'), "application/xml")
#     te = pt1.execute({results: qrda})
    
#    end
  
end