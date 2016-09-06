require 'test_helper'

class Cat3FilterTaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')

    vendor = Vendor.create(name: 'test_vendor_name')
    product = vendor.products.create(name: 'test_product', randomize_records: true, c2_test: true, c4_test: true,
                                     bundle_id: '4fdb62e01d41c820f6000001', measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'])

    product.save!
    options = { 'filters' => { 'genders' => ['F'] } }
    @product_test = product.product_tests.create({ name: 'test_for_measure_1a',
                                                   measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'],
                                                   options: options }, FilteringTest)
  end

  def test_create
    assert @product_test.tasks.create({}, Cat3FilterTask)
  end

  def test_task_good_results_should_pass
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, Cat3FilterTask)
    xml = Tempfile.new(['good_results_debug_file', '.xml'])
    xml.write task.good_results
    perform_enqueued_jobs do
      te = task.execute(xml)
      te.reload
      assert_empty te.execution_errors, 'test execution with known good results should not have any errors'
    end
  end
end
