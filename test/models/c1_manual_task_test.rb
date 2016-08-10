require 'test_helper'

class C1ManualTaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')

    vendor = Vendor.create(name: 'test_vendor_name')
    product = vendor.products.create(name: 'test_product', randomize_records: true, c1_test: true,
                                     bundle_id: '4fdb62e01d41c820f6000001', measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'])

    product.save!
    @checklist_test = product.product_tests.build({ name: 'c1 visual', measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'] }, ChecklistTest)
    @checklist_test.save!
    @checklist_test.create_checked_criteria
    simplify_criteria
    C1ManualTask.new(product_test: @checklist_test).save!
  end

  def test_create
    assert @checklist_test.tasks.create({}, C1ManualTask)
  end

  def test_task_good_results_should_pass
    task = @checklist_test.tasks[0]
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/c1_manual_correct_codes.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip)
      te.reload
      @checklist_test.reload
      assert @checklist_test.checked_criteria.first.complete?, 'checklist test criteria should be true with QRDA entry'
      assert @checklist_test.checked_criteria.last.complete?, 'checklist test criteria should be true with QRDA entry'
    end
  end

  def test_task_bad_results_should_fail
    task = @checklist_test.tasks[0]
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/c1_manual_incorrect_codes.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip)
      te.reload
      assert_not @checklist_test.checked_criteria.first.complete?, 'checklist test criteria should be false with incorrect QRDA entry'
      assert_not @checklist_test.checked_criteria.last.complete?, 'checklist test criteria should be false with incorrect QRDA entry'
    end
  end

  def test_execute_should_not_execute_a_sibling_execution_on_c3_manual_task_if_c3_not_selected
    Task.destroy_all
    task = @checklist_test.tasks.create!({}, C1ManualTask)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/c1_manual_correct_codes.zip'))
    perform_enqueued_jobs do
      execution = task.execute(zip)
      assert execution
      assert_equal 1, @checklist_test.tasks.count { |t| t.test_executions.any? }, 'only one task with any test executions'
      assert_equal 1, @checklist_test.tasks.count { |t| t.test_executions.count }, 'only one test execution for checklist test'
      assert_equal 1, task.test_executions.count
    end
  end

  def test_execute_should_execute_a_sibling_execution_on_c3_manual_task_if_c3_selected
    Task.destroy_all

    # select c3 on product
    product = @checklist_test.product
    product.c3_test = true
    product.save!

    task = @checklist_test.tasks.create!({}, C1ManualTask)
    @checklist_test.tasks.create!({}, C3ManualTask)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/c1_manual_correct_codes.zip'))
    perform_enqueued_jobs do
      execution = task.execute(zip)
      assert execution
      assert_equal 2, @checklist_test.tasks.count { |t| t.test_executions.any? }, 'two tasks (one c1, one c3), both with test executions'
      assert_equal 2, @checklist_test.tasks.count { |t| t.test_executions.count }, 'two test execution for checklist test'
      assert_equal 1, task.test_executions.count
      sibling_task = task.test_executions.first.sibling_execution.task
      assert_equal 1, sibling_task.test_executions.count
    end
  end

  def simplify_criteria
    criteria = @checklist_test.checked_criteria[0, 2]
    criteria[0].source_data_criteria = 'DiagnosisActiveMajorDepressionIncludingRemission_precondition_40'
    criteria[0].code = '14183003'
    criteria[0].code_complete = true
    criteria[0].attribute_code = '63161005'
    criteria[0].attribute_complete = true
    criteria[1].source_data_criteria = 'PatientCharacteristicEthnicityEthnicity'
    criteria[1].code = '2186-5'
    criteria[1].code_complete = true
    @checklist_test.checked_criteria = criteria
    @checklist_test.save!
  end
end
