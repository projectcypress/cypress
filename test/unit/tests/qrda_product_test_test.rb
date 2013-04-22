class QRDAProductTestTest  < ActiveSupport::TestCase

  setup do
    
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('product_tests', '_id','bundle_id')
    collection_fixtures('products', '_id')
    collection_fixtures('bundles','_id')
    collection_fixtures('measures','_id','bundle_id')
    collection_fixtures('records','_id', "bundle_id", "test_id")
    collection_fixtures('patient_cache','_id','bundle_id') 

  end


  test "should be able to retrieve all measures for test creation" do 
    measures = QRDAProductTest.product_type_measures(Bundle.active.first)
    assert_equal Bundle.active.first.measures.top_level.count, measures.count, "Measure count incorrect"
    
  end

test "should be able to create and execute a test" do

  	measure_ids = ["0001","0002"]

  	pt = QRDAProductTest.new(bundle_id: Bundle.first.id,measure_ids: measure_ids, name:"In Test", product_id: Product.first.id,effective_date:Bundle.active.first.effective_date)
 
  	pt.save
  	pt.reload

  	assert_equal "ready", pt.state, "Test should be in a ready state"
  	assert_equal measure_ids, pt.measures.collect{|m| m.hqmf_id}, "Test should have the same measure_ids created with"

    assert_equal 1, pt.records.count , "Test should have created 1 record"
    qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/eh_test_results.xml'), "application/xml")
    
    execution = pt.execute({:results =>qrda})
    assert_equal 0,  execution.execution_errors.by_validation_type(:result_validation).length 
    qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/eh_test_results_bad.xml'), "application/xml")
    
    execution = pt.execute({:results =>qrda})

    assert execution, "Should be able to create and execution"

	
  end


  test "should be able to test a good archive of qrda files"  do 
    ptest = ProductTest.find("51703a883054cf84390000d3")
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip'))
    te = ptest.execute({results: zip})
    assert te.execution_errors.empty?, "should be no errors for good cat I archive" 
  end


  test "should be able to tell when wrong number of documents are supplied in archive" do
    ptest = ProductTest.find("51703a883054cf84390000d3")
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_many_files.zip'))
    te = ptest.execute({results: zip})
    assert_equal 1, te.execution_errors.length , "should be 1 error from cat I archive" 
  
  end


  test "should be able to tell when wrong names are provided in documents" do
    ptest = ProductTest.find("51703a883054cf84390000d3")
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_wrong_names.zip'))
    te = ptest.execute({results: zip})
    assert_equal 1, te.execution_errors.length , "should be 1 error from cat I archive" 
  
  end

  test "should be able to tell when potentially to much data is in documents" do
    ptest = ProductTest.find("51703a883054cf84390000d3")
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_much_data.zip'))
    te = ptest.execute({results: zip})
    assert_equal 1, te.execution_errors.length , "should be 1 error from cat I archive" 
  
  end


  

end
