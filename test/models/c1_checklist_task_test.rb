require 'test_helper'

class C1ChecklistTaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    product = FactoryBot.create(:product_static_bundle)
    @checklist_test = product.product_tests.build({ name: 'c1 visual', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, ChecklistTest)
    @checklist_test.save!
    @checklist_test.create_checked_criteria
    simplify_criteria(@checklist_test)
    C1ChecklistTask.new(product_test: @checklist_test).save!
  end

  def test_create
    assert @checklist_test.tasks.create({}, C1ChecklistTask)
  end

  def test_task_good_results_should_pass
    task = @checklist_test.tasks[0]
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_correct_codes.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, User.first)
      te.reload
      @checklist_test.reload
      assert @checklist_test.checked_criteria.first.complete?, 'checklist test criteria should be true with QRDA entry'
      assert @checklist_test.checked_criteria.last.complete?, 'checklist test criteria should be true with QRDA entry'
    end
  end

  def test_task_bad_results_should_fail
    task = @checklist_test.tasks[0]
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_incorrect_codes.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, User.first)
      te.reload
      assert_not @checklist_test.checked_criteria.first.complete?, 'checklist test criteria should be false with incorrect QRDA entry'
      assert_not @checklist_test.checked_criteria.last.complete?, 'checklist test criteria should be false with incorrect QRDA entry'
    end
  end

  def test_execute_should_not_execute_a_sibling_execution_on_c3_checklist_task_if_c3_not_selected
    Task.destroy_all
    task = @checklist_test.tasks.create!({}, C1ChecklistTask)
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_correct_codes.zip'))
    perform_enqueued_jobs do
      execution = task.execute(zip, User.first)
      assert execution
      assert_equal 1, @checklist_test.tasks.count { |t| t.test_executions.any? }, 'only one task with any test executions'
      assert_equal 1, @checklist_test.tasks.count { |t| t.test_executions.count }, 'only one test execution for checklist test'
      assert_equal 1, task.test_executions.count
    end
  end

  def test_execute_should_execute_a_sibling_execution_on_c3_checklist_task_if_c3_selected
    Task.destroy_all

    # select c3 on product
    product = @checklist_test.product
    product.c3_test = true
    product.save!

    task = @checklist_test.tasks.create!({}, C1ChecklistTask)
    @checklist_test.tasks.create!({}, C3ChecklistTask)
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_correct_codes.zip'))
    perform_enqueued_jobs do
      execution = task.execute(zip, User.first)
      assert execution
      assert_equal 2, @checklist_test.tasks.count { |t| t.test_executions.any? }, 'two tasks (one c1, one c3), both with test executions'
      assert_equal 2, @checklist_test.tasks.count { |t| t.test_executions.count }, 'two test execution for checklist test'
      assert_equal 1, task.test_executions.count
      sibling_task = task.test_executions.first.sibling_execution.task
      assert_equal 1, sibling_task.test_executions.count
    end
  end
end
