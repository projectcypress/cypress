require 'test_helper'
class VendorsHelperTest < ActionView::TestCase
    
    setup do
        collection_fixtures('vendors', '_id')
        collection_fixtures('test_executions', '_id', "product_test_id")
        collection_fixtures('products', '_id','vendor_id')
        collection_fixtures('product_tests', '_id','product_id')
    end

    test "products by status" do 
        Vendor.each do |vendor|

        results = products_by_status(vendor)
        assert_equal results["fail"] ,vendor.failing_products
        assert_equal results["pass"] , vendor.passing_products
        assert_equal results["incomplete"], vendor.incomplete_products
        end
    end
end