require 'test_helper'

class VendorTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('vendors', '_id')
    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id')
    collection_fixtures('measures')
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
    
    assert failing3.size == 0 , "Empty vendor reporting failing products"
    assert failing2.size == 0 , "Vendor reporting wrong number of failing products"
    assert failing1.size == 2 , "Vendor reporting wrong number of failing products"
    assert failing1[0]._id.to_s == "4f57a88a1d41c851eb000004" , "Vendor reporting wrong failing product"
  end

  test "Should return passing products" do
    passing1 = @vendor1.passing_products
    passing2 = @vendor2.passing_products
    passing3 = @emptyVendor.passing_products

    assert passing3.size == 0 , "Empty vendor reporting passing products"
    assert passing1.size == 1 , "Vendor reporting wrong number of passing products"
    assert passing2.size == 1 , "Vendor reporting wrong number of passing products"
    assert passing1[0]._id.to_s == "4f6b77831d41c851eb0004a5" , "Vendor reporting wrong passing product"
    assert passing2[0]._id.to_s == "4f636ae01d41c851eb00048e" , "Vendor reporting wrong passing product"
  end
  
  test "Should know if all products are passing" do
    assert !@vendor1.passing? , "Failing vendor reporting as passing"
    assert @vendor2.passing? , "Passing vendor reporting as failing"
    #assert !@emptyVendor.passing? , "Empty vendor reporting as passing"
  end
  
  test "Should know how many products are passing" do
    assert @vendor1.count_passing == 1 , "Vendor reporting wrong number of passing products"
    assert @vendor2.count_passing == 1 , "Vendor reporting wrong number of passing products"
    assert @emptyVendor.count_passing == 0, "Empty vendor reporting wrong number of passing products"
  end
  
  test "Should return product passing rate" do
    assert @vendor1.success_rate == 1.0/3.0 , "Vendor reporting wrong success rate"
    assert @vendor2.success_rate == 1.0 , "Vendor reporting wrong success rate"
    assert @emptyVendor.success_rate == 0.0 , "Empty vendor reporting wrong success rate"
  end
  
end