class CalculatedProductTestTest < ActiveSupport::TestCase

  setup do
    
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('product_tests', '_id','bundle_id', 'product_id', 'user_id')
    collection_fixtures('bundles','_id')
    collection_fixtures('measures','_id','bundle_id')
  end


  
  test "execute qrda" do
#    binding.pry
    pt1 = ProductTest.find("4f58f8de1d41c851eb000999")
    ex_count = TestExecution.where(:product_test_id => pt1.id).count

    qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'), "application/xml")
    te = pt1.execute({results: qrda})
    
   end
  

  #  test "Generate QRDA Test" do
  #   pt1 = ProductTest.find("4f58f8de1d41c851eb000999")
    
  #   pt1.generate_qrda_cat1_test

  #   # should generate a QRDA Cat I test for each measure
  #   pt1.measures.each do |mes|
  #     qrda_test = QRDAProductTest.where({calculated_test_id: pt1.id, measure_ids: mes.hqmf_id})
  #     assert_equal 1, qrda_test.count
  #     qrda = qrda_test.first
  #     assert_equal 1, qrda.measures.count, "Generated QRDA Cat I test should only have 1 measure"
  #     assert_equal pt1.effective_date ,qrda.effective_date
  #     assert_equal pt1.bundle_id, qrda.bundle_id
  #     assert_equal pt1.product_id ,qrda.product_id
  #     assert_equal pt1.user_id,  qrda.user_id
  #   end
    
  # end


   test "Generate QRDA Test" do
    pt1 = ProductTest.find("4f58f8de1d41c851eb000999")
    
    pt1.generate_qrda_cat1_test
    qrda_test = QRDAProductTest.where({calculated_test_id: pt1.id})
    assert_equal pt1.measures.count, qrda_test.count
    qrda = qrda_test.first
    assert_equal 1, qrda.measures.count, "Generated QRDA Cat I test should only have the same number of measures as the calculated test"
    assert_equal pt1.effective_date ,qrda.effective_date
    assert_equal pt1.bundle_id, qrda.bundle_id
    assert_equal pt1.product_id ,qrda.product_id
    assert_equal pt1.user_id,  qrda.user_id
  
  end


  test "should execute a test with 0 errors for correct cat III file" do 
    ptest = ProductTest.find("51703a6a3054cf8439000044")
    xml = Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_good.xml')), "application/xml")
    te = ptest.execute({results: xml})
    assert te.execution_errors.empty?, "should be no errors for good cat I archive" 
  end


  test "should cause error  when stratifications are missing" do 
    ptest = ProductTest.find("51703a6a3054cf8439000044")
    xml = Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_stratification.xml')), "application/xml")
    te = ptest.execute({results: xml})
    # Missing strat for the 1 numerator that has data
    assert_equal 1,te.execution_errors.length, "should error on missing stratifications" 
  end

  test "should cause error  when supplemental data is missing" do 
    ptest = ProductTest.find("51703a6a3054cf8439000044")
    xml = Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_supplemental.xml')), "application/xml")
    te = ptest.execute({results: xml})
    # checked 3 times for each numerator -- we should do something about that
    assert_equal 3 ,te.execution_errors.length, "should error on missing supplemetnal data" 
  end

  test "should cause error  when not all populations are accounted for" do

    ptest = ProductTest.find("51703a6a3054cf8439000044")
    xml = Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_stratification.xml')), "application/xml")
    te = ptest.execute({results: xml})

    assert_equal 1 ,te.execution_errors.length, "should error on missing populations" 

  end

  test "should cause error  when the schema structure is bad" do
    ptest = ProductTest.find("51703a6a3054cf8439000044")
    xml = Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_bad_schematron.xml')), "application/xml")
    te = ptest.execute({results: xml})
    # 3 errors 1 for schema validation and 2 schematron issues for realmcode
    assert_equal 3, te.execution_errors.length, "should error on bad schematron" 
  end

  test "should cause error  when measure is not included in report" do
    ptest = ProductTest.find("51703a6a3054cf8439000044")
    xml = Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_missing_measure.xml')), "application/xml")
    te = ptest.execute({results: xml})
    # 9 is for all of the sub measures to be searched for
    assert_equal 9, te.execution_errors.length, "should error on missing measure entry" 
  end

  test "should cause error  when extra supplemental data is provided" do
    ptest = ProductTest.find("51703a6a3054cf8439000044")
    xml = Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_extra_supplemental.xml')), "application/xml")
    te = ptest.execute({results: xml})
    # 1 Error for additional Race 
    assert_equal 1 ,te.execution_errors.length, "should error on additional supplemental data" 
  end

  
end