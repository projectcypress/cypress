require 'test_helper'
class TestExecutionTest < ActiveSupport::TestCase
  def setup
    drop_database
    collection_fixtures('measures', 'bundles')
    vendor = Vendor.create(name: 'test_vendor_name')
    product = vendor.products.create(name: 'test_product')
    @ptest = product.product_tests.build(name: 'ptest', measure_ids: ['1a'])
    @task = @ptest.tasks.build
  end

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

  def test_qrda_reporting_and_submission_errors
    qrda_errors = [
      { validator: 'CDA SDTC Validator' },
      { validator: 'QRDA Cat 1 R3 Validator' },
      { validator: 'QRDA Cat 1 Validator' },
      { validator: 'QRDA Cat 3 Validator' },
      { :validator_type => :xml_validation }
    ]
    reporting_errors = [
      { validator: 'Cat 1 Measure ID Validator' },
      { validator: 'Cat 3 Measure ID Validator' },
      { :validator_type => :result_validation }
    ]
    submission_errors = [
      { :validator_type => :submission_validation }
    ]
    execution_errors = qrda_errors + reporting_errors + submission_errors

    te = TestExecution.new(execution_errors: execution_errors)

    assert_equal te.execution_errors.qrda_errors.count, qrda_errors.count
    assert_equal te.execution_errors.reporting_errors.count, reporting_errors.count
    assert_equal te.execution_errors.submission_errors.count, submission_errors.count
  end

  def test_validate_artifact_builds_execution_errors_for_incomplete_checked_criteria
    measure_ids = ['40280381-4B9A-3825-014B-C1A59E160733']
    vendor = Vendor.new(name: "my vendor #{rand}")
    vendor.save!
    product = vendor.products.create!(name: "my product #{rand}", measure_ids: measure_ids, bundle_id: '4fdb62e01d41c820f6000001', c1_test: true)
    test = product.product_tests.create!({ name: "my checklist test #{rand}", measure_ids: measure_ids }, ChecklistTest)
    test.create_checked_criteria
    task = test.tasks.create!({}, C1ManualTask)
    execution = task.test_executions.build

    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/c1_manual_incorrect_codes.zip'))
    execution.artifact = Artifact.new(file: zip)

    execution.validate_artifact(task.validators, execution.artifact)
    num_failed_criteria = test.checked_criteria.select { |crit| !crit.passed_qrda }.count
    assert_equal num_failed_criteria, execution.execution_errors.select { |err| err.validator == 'qrda_cat1' }.count
  end
end
