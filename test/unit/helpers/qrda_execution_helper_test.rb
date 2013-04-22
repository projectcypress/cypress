require 'test_helper'

class QrdaExecutionHelperTest < ActionView::TestCase


	setup do

		collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('product_tests', '_id')
		@pt = ProductTest.find("4f58f8de1d41c851eb000478")
	end

	test "aggregated_measure_results" do 

		results = aggregated_measure_results(@pt)
		assert results
	end


	test "map errors" do 
		qrda = Rack::Test::UploadedFile.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'), "application/xml")
    te = @pt.execute({results: qrda})
    doc,error_map, error_attr = match_errors(qrda.read, te.execution_errors)
    assert doc
    assert error_map
    assert error_attr
	end

end