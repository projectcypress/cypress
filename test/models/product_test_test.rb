require 'test_helper'

class ProductTestTest < ActiveJob::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
    @vendor = Vendor.create(name: 'test_vendor_name')
    @product = @vendor.products.create(name: 'test_product', c2_test: true, randomize_records: true,
                                       bundle_id: '4fdb62e01d41c820f6000001')
  end

  def test_create
    assert_enqueued_jobs 0
    pt = @product.product_tests.build(name: 'test_for_measure_1a', measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'])
    assert pt.valid?, 'product test should be valid with product, name, and measure_id'
  end

  def test_required_fields
    pt = @product.product_tests.build
    assert_equal false,  pt.valid?, 'product test should not be valid without a name'
    assert_equal false,  pt.save, 'should not be able to save product test without a name'
    errors = pt.errors
    assert errors.key?(:name)
    assert errors.key?(:measure_ids)
  end

  def test_status_passing
    measure_id = '40280381-4BE2-53B3-014C-0F589C1A1C39'
    vendor = Vendor.create!(name: 'my vendor')
    product = vendor.products.build(name: 'my product', bundle_id: '4fdb62e01d41c820f6000001', c1_test: true, c2_test: true,
                                    measure_ids: [measure_id])
    product.save!
    measure_test = product.product_tests.build({ name: "my measure test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
    measure_test.save!
    create_test_executions_with_state(measure_test, :passed)
    assert_equal 'passing', measure_test.status

    # measure test should be incomplete if at least one test execution is incomplete
    te = measure_test.tasks[0].test_executions.build(:state => :incomplete)
    te.save!
    assert_equal 'incomplete', measure_test.status

    # measure test should be failing if at least one test execution is failing
    te = measure_test.tasks[1].test_executions.build(:state => :failed)
    te.save!
    assert_equal 'failing', measure_test.status
  end

  # # # # # # # # # # # # # # # # # # # #
  #   H E L P E R   F U N C T I O N S   #
  # # # # # # # # # # # # # # # # # # # #

  def create_test_executions_with_state(product_test, state)
    product_test.tasks.each do |task|
      test_execution = task.test_executions.build(state: state)
      test_execution.save!
    end
  end
end
