require 'test_helper'

class VendorTest < ActiveSupport::TestCase

  setup do

    collection_fixtures('vendors', '_id')
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id')
    collection_fixtures('measures', '_id')
    collection_fixtures('query_cache','_id','test_id')
    collection_fixtures('patient_cache','_id')
    
    @vendor1 = Vendor.find("4f57a8791d41c851eb000002")
    @vendor2 = Vendor.find("4f636aba1d41c851eb00048c")
    @emptyVendor = Vendor.new()
  
  end

  test "Should return failing products" do
    failing1 = @vendor1.failing_products
    failing2 = @vendor2.failing_products
    failing3 = @emptyVendor.failing_products
    
    assert_equal 0, failing3.size  , "Empty vendor reporting failing products"
    assert_equal 0, failing2.size  , "Vendor reporting wrong number of failing products"
    assert_equal 1, failing1.size  , "Vendor reporting wrong number of failing products"
    assert_equal "4f57a88a1d41c851eb000004", failing1[0]._id.to_s  , "Vendor reporting wrong failing product"
  end

  test "Should return passing products" do
    passing1 = @vendor1.passing_products
    passing2 = @vendor2.passing_products
    passing3 = @emptyVendor.passing_products

    assert_equal 0, passing3.size , "Empty vendor reporting passing products"
    assert_equal 2, passing1.size , "Vendor reporting wrong number of passing products"
    assert_equal 1, passing2.size , "Vendor reporting wrong number of passing products"
    assert_equal "4f6b77831d41c851eb0004a5", passing1[0]._id.to_s  , "Vendor reporting wrong passing product"
    assert_equal "4f636ae01d41c851eb00048e",  passing2[0]._id.to_s  , "Vendor reporting wrong passing product"
  end
  

  
  test "Should know how many products are passing" do

    assert_equal 2, @vendor1.count_passing , "Vendor reporting wrong number of passing products"
    assert_equal 1, @vendor2.count_passing , "Vendor reporting wrong number of passing products"
    assert_equal 0, @emptyVendor.count_passing , "Empty vendor reporting wrong number of passing products"
  end
  
  test "Should return product passing rate" do
    assert_equal 2.0/3.0, @vendor1.success_rate , "Vendor reporting wrong success rate"
    assert_equal 1.0,  @vendor2.success_rate  , "Vendor reporting wrong success rate"
    assert_equal 0.0, @emptyVendor.success_rate  , "Empty vendor reporting wrong success rate"
  end
  
end