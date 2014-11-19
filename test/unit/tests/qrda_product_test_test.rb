class QRDAProductTestTest  < ActiveSupport::TestCase

  setup do

    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('product_tests', '_id','bundle_id')
    collection_fixtures('products', '_id')
    collection_fixtures('bundles','_id')
    collection_fixtures('measures','_id','bundle_id')
    collection_fixtures('records','_id', "bundle_id", "test_id")
    collection_fixtures2('patient_cache','value', '_id' ,'test_id','bundle_id')
    collection_fixtures('health_data_standards_svs_value_sets', '_id','bundle_id')
  end


  test "should be able to retrieve all measures for test creation" do
    measures = QRDAProductTest.product_type_measures(Bundle.active.first)
    assert_equal Bundle.active.first.measures.top_level.count, measures.count, "Measure count incorrect"

  end


  test "should be able to test a good archive of qrda files"  do
    ptest = ProductTest.find("51703a883054cf84390000d3")
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip'))
    te = ptest.execute(zip)
    assert te.execution_errors.empty?, "should be no errors for good cat I archive"
  end


  test "should be able to tell when wrong number of documents are supplied in archive" do
    ptest = ProductTest.find("51703a883054cf84390000d3")
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_many_files.zip'))
    te = ptest.execute(zip)
    assert_equal 1, te.execution_errors.length , "should be 1 error from cat I archive"

  end


  test "should be able to tell when wrong names are provided in documents" do
    ptest = ProductTest.find("51703a883054cf84390000d3")
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_wrong_names.zip'))
    te = ptest.execute(zip)
    assert_equal 2, te.execution_errors.length , "should be 2 errors from cat I archive"

  end

  test "should be able to tell when potentially too much data is in documents" do
    ptest = ProductTest.find("51703a883054cf84390000d3")
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_much_data.zip'))
    te = ptest.execute(zip)
    assert_equal 2, te.execution_errors.length , "should be 2 errors from cat I archive"

  end




end
