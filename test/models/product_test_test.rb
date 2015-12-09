require 'test_helper'

class ProductTestTest < ActiveJob::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
    vendor = Vendor.create(name: 'test_vendor_name')
    @product = vendor.products.create(name: 'test_product',c2_test: true)
  end

  def after_teardown
    drop_database
  end

  def test_create
    assert_enqueued_jobs 0
    pt = @product.product_tests.build(name: 'test_for_measure_1a',
                                      measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'],
                                      bundle_id: '4fdb62e01d41c820f6000001')
    assert pt.valid?, 'product test should be valid with product, name, and measure_id'
    perform_enqueued_jobs do
      assert pt.save, 'should be able to save valid product test'
      assert_performed_jobs 1
      assert pt.records.count > 0, 'product test creation should have created random number of test records'
      pt.reload
      assert_not_nil pt.patient_archive, "Product test should have archived patient records"
      assert_not_nil pt.expected_results, "Product test should have expected results"
    end
  end

  def test_required_fields
    pt = @product.product_tests.build
    assert_equal false,  pt.valid?, 'product test should not be valid without a name'
    assert_equal false,  pt.save, 'should not be able to save product test without a name'
    errors = pt.errors
    assert errors.key?(:name)
    assert errors.key?(:measure_ids)
  end

  def test_has_c3_task
    pt = @product.product_tests.build(name: 'test_for_measure_1a',
                                      measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'],
                                      bundle_id: '4fdb62e01d41c820f6000001')
    pt.save
    assert !pt.contains_c3_task?

    pt.tasks.create({}, C3Task)
    assert pt.contains_c3_task?
  end
end
