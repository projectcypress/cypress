class CalculatedProductTestTest < ActiveSupport::TestCase

  setup do
    
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('product_tests', '_id')
  end

 
  
  
  test "should clone records when given patient_ids " do
    pending "until I can get the fixtures fixed to deal with this" do
      Delayed::Worker.delay_jobs = false
      patients = ['100','102']
      measures = ['0001']
      pt = CalculatedProductTest.new({measure_ids: measures, patient_ids: patients, effective_date: Time.now.to_i, name: "Test"})

      pt.save
      
      Delayed::Worker.delay_jobs = true
      assert_equal :ready, pt.state, "State should be ready"
      assert_equal measures,  pt.measure_ids , "Test should have the same measure_ids created with"
      assert pt.expected_results, "Test should have expected results"
      assert_equal patients.length, pt.records.count , "Test should have the correct number of patient records"
    end
    
  end
  
  
  
  test "execute qrda" do
#    binding.pry
    pt1 = ProductTest.find("4f58f8de1d41c851eb000999")
    ex_count = TestExecution.where(:product_test_id => pt1.id).count

    qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'), "application/xml")
    te = pt1.execute({results: qrda})
    
   end
  
end