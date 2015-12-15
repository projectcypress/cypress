require 'test_helper'
class MeasureTestTest < ActiveSupport::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
    vendor = Vendor.create!(name: 'test_vendor_name')
    @product = vendor.products.create(name: 'test_product')
  end

  def test_more_than_one_measure
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: %w(0001 0002) }, MeasureTest)
    assert_equal false,  pt.valid?, 'product test should not be valid without a '
    assert_equal false,  pt.save, 'should not be able to save product test with more than 1 measure id'
    errors = pt.errors
    assert errors.key?(:measure_ids)
  end

  def test_single_measure
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    assert_equal true,  pt.valid?, 'product test should be valid with single measure id'
    assert_equal true,  pt.save, 'should save with single measure id'
  end

  def test_create_task_c1
    @product.c1_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    pt.create_tasks
    assert pt.c1_task, 'product test should have a c1_task'
    assert_equal false, pt.c2_task, 'product test should not have a c2_task'
    assert_equal false, pt.c3_task, 'product test should not have a c3_task'
  end

  def test_create_task_c2
    @product.c2_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    pt.create_tasks
    assert_equal false, pt.c1_task, 'product test should not have a c1_task'
    assert pt.c2_task, 'product test should have a c2_task'
    assert_equal false, pt.c3_task, 'product test should not have a c3_task'
  end

  def test_create_task_c3_creates_c1_and_c2_also
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    pt.create_tasks
    assert pt.c1_task, 'product test should have a c1_task'
    assert pt.c2_task, 'product test should have a c2_task'
    assert pt.c3_task, 'product test should have a c3_task'
  end

  def test_create_task_c1_and_c2
    @product.c1_test = true
    @product.c2_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    pt.create_tasks
    assert pt.c1_task, 'product test should have a c1_task'
    assert pt.c2_task, 'product test should have a c2_task'
    assert_equal false, pt.c3_task, 'product test should not have a c3_task'
  end

  def test_create_task_c1_and_c3
    @product.c1_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    pt.create_tasks
    assert pt.c1_task, 'product test should have a c1_task'
    assert_equal false, pt.c2_task, 'product test should not have a c2_task'
    assert pt.c3_task, 'product test should have a c3_task'
  end

  def test_create_task_c2_and_c3
    @product.c2_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    pt.create_tasks
    assert_equal false, pt.c1_task, 'product test should not have a c1_task'
    assert pt.c2_task, 'product test should have a c2_task'
    assert pt.c3_task, 'product test should have a c3_task'
  end

  def test_create_task_c1_c2_and_c3
    @product.c1_test = true
    @product.c2_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['0001'], bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
    pt.create_tasks
    assert pt.c1_task, 'product test should have a c1_task'
    assert pt.c2_task, 'product test should have a c2_task'
    assert pt.c3_task, 'product test should have a c3_task'
  end
end
