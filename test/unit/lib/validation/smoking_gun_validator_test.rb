class SmokingGunValidatorTest < ActiveSupport::TestCase

	setup do 
		# needs
		# a test with a measure and records
		# record with results with rationale that meet the IPP of meausre in test
    collection_fixtures('product_tests', '_id','bundle_id')
    collection_fixtures('products', '_id')
    collection_fixtures('bundles','_id')
    collection_fixtures('measures','_id','bundle_id')
    collection_fixtures('records','_id', "bundle_id", "test_id")
    collection_fixtures('patient_cache','_id','bundle_id') 

    @ptest = ProductTest.find("51703a883054cf84390000d3")
    @validator = SmokingGunValidator.new(@ptest.measures, @ptest.records, {"value.test_id" => @ptest.id})
	end

	


end