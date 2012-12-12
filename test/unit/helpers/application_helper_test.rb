require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
	test "Should return formatted time" do
		now = Time.now
		formatted_time = now.strftime('%m/%d/%Y')

		assert display_time(now) == formatted_time
		assert display_time('fail') == '?'
	end



  test "Should return correct test execution template" do
		assert_equal "test_executions/show", test_execution_template(CalculatedProductTest.new.test_executions.build)
		assert_equal "test_executions/show", test_execution_template(InpatientProductTest.new.test_executions.build)
		assert_equal "test_executions/qrda_product_test/show", test_execution_template(QRDAProductTest.new.test_executions.build)
	end

	test "Submit Method " do
	end

	test "" do 

	end


end
