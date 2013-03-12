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
  

   test "Generate QRDA Test" do
    pt1 = ProductTest.find("4f58f8de1d41c851eb000999")
    qrda = pt1.generate_qrda_cat1_test
    assert_equal QRDAProductTest , qrda.class 
    assert_equal pt1.measure_ids , qrda.measure_ids
    assert_equal pt1.effective_date ,qrda.effective_date
    assert_equal pt1.bundle_id, qrda.bundle_id
    assert_equal pt1.product_id ,qrda.product_id
    assert_equal pt1.user_id,  qrda.user_id
  end
end