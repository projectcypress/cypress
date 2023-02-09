# frozen_string_literal: true

require 'test_helper'
class TestExecutionTest < ActiveSupport::TestCase
  def setup
    @bundle = FactoryBot.create(:static_bundle)
    vendor = Vendor.create(name: 'test_vendor_name')
    product = vendor.products.create(name: 'test_product', bundle_id: @bundle.id)
    @ptest = product.product_tests.build(name: 'ptest', measure_ids: ['1a'])
    @task = @ptest.tasks.build
  end

  def test_create
    user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    te = @task.test_executions.build
    user.test_executions << te
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

  def test_errored_should_contain_backtrace
    se = StandardError.new('message')
    se.set_backtrace(%w[line1 line2])

    te = TestExecution.new
    te.save

    te.errored(se)

    assert_equal te.backtrace, "message\nline1\nline2", 'te.errored doesn\'t set the correct backtrace message'
    assert_equal te.error_summary, 'Errored validating : message on line1', 'te.errored doesn\'t set the correct backtrace message'

    assert te.errored?, 'te.errored? not returning true when execution is errored'
  end

  def test_validate_artifact_builds_execution_errors_for_incomplete_checked_criteria
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    vendor = Vendor.new(name: "my vendor #{rand}")
    vendor.save!
    product = vendor.products.create!(name: "my product #{rand}", measure_ids:, bundle_id: @bundle.id, c1_test: true)
    test = product.product_tests.create!({ name: "my checklist test #{rand}", measure_ids: }, ChecklistTest)
    test.create_checked_criteria
    task = test.tasks.create!({}, C1ChecklistTask)
    execution = task.test_executions.build
    Tracker.create(options: { test_execution_id: execution.id })

    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_incorrect_codes.zip'))
    execution.artifact = Artifact.new(file: zip)

    execution.validate_artifact(task.validators, execution.artifact, task:)
    num_failed_criteria = test.checked_criteria.reject(&:passed_qrda).count
    assert_equal num_failed_criteria, execution.execution_errors.select { |err| err.validator == 'qrda_cat1' }.count
    assert_equal execution.tracker.log_message[0], '1 of 1 files validated'
  end

  def test_executions_pending
    user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    vendor = Vendor.create!(name: "my vendor #{rand}")
    product = vendor.products.create!(name: "my product #{rand}", measure_ids:, bundle_id: @bundle.id, c1_test: true,
                                      c3_test: true)
    test = product.product_tests.create({ name: "measure test for measure #{measure_ids.first}", measure_ids: }, MeasureTest)
    c1_task = test.tasks.create({}, C1Task)
    c3_task = test.tasks.create({}, C3Cat1Task)
    c1_execution = c1_task.test_executions.create(state: :pending, user:)
    assert_equal true, c1_execution.executions_pending?

    c1_execution.update(state: :passed)
    assert_equal false, c1_execution.executions_pending?

    c3_execution = c3_task.test_executions.create(state: :pending, sibling_execution_id: c1_execution.id, user:)
    c1_execution.sibling_execution_id = c3_execution.id
    assert_equal true, c1_execution.executions_pending?

    c3_execution.update(state: :failed)
    assert_equal false, c1_execution.executions_pending?
  end

  def test_limit_warnings
    vendor = Vendor.create(name: 'limited_vendor_name')
    product = vendor.products.create(name: 'limited_product', bundle_id: @bundle.id)
    ptest = product.product_tests.build(name: 'ptest', measure_ids: ['AE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    task = ptest.tasks.build
    te = task.test_executions.build

    # If the root and translation codes are from the same valueset(s), the warning will be removed
    trans_code_string = '2.16.840.1.113883.6.96:720'
    root_code_string = '2.16.840.1.113883.6.96:720'
    te.execution_errors << ExecutionError.new(message: "Translation code #{trans_code_string} may not be used for eCQM calculation by a receiving system. Ensure that the root code #{root_code_string} is from an eCQM valueset.", msg_type: :warning)
    te.limit_translation_warnings(te.execution_errors.only_warnings)
    assert_equal 0, te.execution_errors.size

    # If the root and translation codes are not from the same valueset(s), the warning will not be removed
    root_code_string = '2.16.840.1.113883.6.96:bad_code'
    te.execution_errors << ExecutionError.new(message: "Translation code #{trans_code_string} may not be used for eCQM calculation by a receiving system. Ensure that the root code #{root_code_string} is from an eCQM valueset.", msg_type: :warning)
    te.limit_translation_warnings(te.execution_errors.only_warnings)
    assert_equal 1, te.execution_errors.size
  end
end
