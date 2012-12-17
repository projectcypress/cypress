require 'test_helper'
class VendorsHelperTest < ActionView::TestCase

	test "products by status" do 
		Vendor.each do |vendor|

		results = products_by_status(vendor)
		assert_equal results["fail"] ,vendor.failing_products
		assert_equal results["pass"] , vendor.passing_products
		assert_equal results["incomplete"], vendor.incomplete_products
		end
	end
end