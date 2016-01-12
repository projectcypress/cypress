require 'test_helper'
class C3TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @product_test = ProductTest.find('51703a883054cf84390000d3')
  end

  def test_create
    ptest = ProductTest.find('51703a883054cf84390000d3')
    assert ptest.tasks.create({}, C3Task)
  end

  def test_should_include_c3_validators_when_cat1_c3_exists
    task = @product_test.tasks.create({}, C3Task)
    @product_test.tasks.create({}, C3Task)
    assert @product_test.contains_c3_task?
    task.last_execution = 'Cat1'
    assert task.validators.count { |v| v.is_a?(MeasurePeriodValidator) } > 0
  end

  def test_should_include_c3_validators_when_cat3_c3_exists
    task = @product_test.tasks.create({}, C3Task)
    @product_test.tasks.create({}, C3Task)
    assert @product_test.contains_c3_task?
    task.last_execution = 'Cat3'
    assert task.validators.count { |v| v.is_a?(MeasurePeriodValidator) } > 0
  end

  def test_should_cause_error_when_measure_is_not_included_in_report_with_c3
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({}, C3Task)
    task.last_execution = 'Cat3'
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_missing_measure.xml', 'application/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, nil)
      te.reload
      assert_equal 0, te.execution_errors.length, 'should have no errors for the invalid measure ids, this is a c2 validaton'
    end
  end

  def test_should_cause_error_when_performance_rate_is_incorrect_with_c3
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({}, C3Task)
    task.last_execution = 'Cat3'
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_performance_rate.xml', 'application/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, nil)
      te.reload
      assert_equal 1, te.execution_errors.length, 'should have 1 error for the invalid performance rate'
    end
  end

  def test_should_error_when_measure_period_is_wrong
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({}, C3Task)
    task.last_execution = 'Cat3'
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_mp.xml', 'application/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, nil)
      te.reload
      assert_equal 2, te.execution_errors.length, 'should have 2 errors for the invalid reporting period'
    end
  end

end
