class TestExecutionTest < MiniTest::Test

  def setup
    vendor = Vendor.create(name: "test_vendor_name")
    product = vendor.products.create(name: "test_product")
    @ptest = product.product_tests.build(name: "ptest", measure_id: "1a")
  end

  def after_teardown
    Vendor.all.destroy
  end

  def test_create
    te = @ptest.test_executions.build()
    assert te.save, "should be able to create a test execution"
  end
end