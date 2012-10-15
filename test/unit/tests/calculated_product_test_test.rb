class CalculatedProductTestTest < ActiveSupport::TestCase

  setup do
    
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('product_tests', '_id')
  end

  test "Should generate minimal set of records on create " do 
    pending "Need measures and patients that work together so we can determine outcome"  do
        measures = []
        pt = CalculatedProductTest.new({measure_ids: measures})
        pt.save

        assert_equal :ready, pt.state, "State should be ready"
        assert measures == pt.measure_ids , "Test should have the same measure_ids created with"
        assert pt.expected_results, "Test should have expected results"
        assert_equal 0, pt.records.count , "Test should have the correct number of patien records"
        
    end
  
  end
  
  
  test "should clone records when given patient_ids " do
    pending "" do
      patients = []
      measures = []
      pt = CalculatedProductTest.new({measure_ids: measures, patient_ids: patients})
      pt.save
      
      assert_equal :ready, pt.state, "State should be ready"
      assert measures == pt.measure_ids , "Test should have the same measure_ids created with"
      assert pt.expected_results, "Test should have expected results"
      assert_equal patients.length, pt.records.count , "Test should have the correct number of patient records"
    end
    
  end
  

  
  test "should be able to retreive results for a specific measure"  do 
    
  end
  
  
  test "should set state to errored when there was a problem creating the test" do
    
  end
  
  
  test "execute qrda" do
#    binding.pry
    pt1 = ProductTest.find("4f58f8de1d41c851eb000999")
    ex_count = TestExecution.where(:product_test_id => pt1.id).count

    qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'), "application/xml")
    te = pt1.execute({results: qrda})
    
   end
  
end