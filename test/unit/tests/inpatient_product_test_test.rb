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

  # test "should be able to create and execute a test" do
  #       Delayed::Worker.delay_jobs = false
  # 	measure_ids = ["8A4D92B2-3887-5DF3-0139-0D01C6626E46","8A4D92B2-3887-5DF3-0139-0D08A4BE7BE6","8A4D92B2-3887-5DF3-0139-0C4E41594C98"]
  # 	pt = InpatientProductTest.new(measure_ids: measure_ids, name:"In Test", effective_date: Cypress::MeasureEvaluator::STATIC_EFFECTIVE_DATE)
  # 	pt.save

  # 	assert_equal "ready", pt.state, "Test should be in a ready state"
  # 	assert_equal measure_ids.uniq.sort, pt.measures.collect{|m| m.hqmf_id}.uniq.sort, "Test should have the same measure_ids created with"
  #   assert pt.expected_results, "Test should have expected results"
 
  #   pt.measures.each do |mes|
  #   	assert pt.expected_results[mes.key], "Test should contain an expected results for #{mes.key}"
  #   end

  #   assert_equal 6, pt.records.count , "Test should have the correct number of patient records"
  #   qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/eh_test_results.xml'), "application/xml")

  #   execution = pt.execute({:results =>qrda})

  #   assert_equal 0,  execution.execution_errors.by_validation_type(:result_validation).length , "Should have 0 result errors"
  #   qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/eh_test_results_bad.xml'), "application/xml")
    
  #   execution = pt.execute({:results =>qrda})
  #   assert_equal 3,  execution.execution_errors.by_validation_type(:result_validation).length , " Should have 1 result error"
  #   Delayed::Worker.delay_jobs = true

  # end

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