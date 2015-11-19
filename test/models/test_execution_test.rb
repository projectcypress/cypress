require 'test_helper'
class TestExecutionTest < MiniTest::Test
  def setup
    drop_database
    vendor = Vendor.create(name: 'test_vendor_name')
    product = vendor.products.create(name: 'test_product')
    ptest = product.product_tests.build(name: 'ptest', measure_ids: ['1a'])
    @task = ptest.tasks.build
  end

  # def after_teardown
  #   drop_database
  # end

  def test_create
    te = @task.test_executions.build
    assert te.save, 'should be able to create a test execution'
  end

  def test_passed_failed_and_incomplete_methods_should_be_accurate
    te = TestExecution.new
    te.save

    assert te.incomplete?, 'te.imcomplete? should return true when execution is neither passing or failing'

    te.fail
    assert te.failing?, 'te.failing? not returning true when execution is failing'

    te.pass
    assert te.passing?, 'te.passing? not returning true when execution is passing'
  end
end
