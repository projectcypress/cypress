require 'test_helper'
class C3Cat3TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @test = ProductTest.find('51703a883054cf84390000d3')
    @test.product.c3_test = true
    @task = @test.tasks.create({}, C3Cat3Task)
  end

  def test_task_should_include_c3_cat3_validators
    assert @task.validators.count { |v| v.is_a?(MeasurePeriodValidator) } > 0
  end

  def test_should_cause_error_when_measure_is_not_included_in_report_with_c3
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_missing_measure.xml', 'text/xml')
    perform_enqueued_jobs do
      te = @task.execute(xml, nil)
      te.reload
      assert_equal 1, te.execution_errors.length, 'should have no errors for the invalid measure ids, this is a c2 validaton'
      msg = "The document must contain the document level template [templateId with root='2.16.840.1.113883.10.20.27.1.2'] " \
            'for this schematron to be applicable.'
      assert_equal msg, te.execution_errors[0].message, 'single error must be for missing template id'
    end
  end

  def test_should_cause_error_when_performance_rate_is_incorrect_with_c3
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_performance_rate.xml', 'text/xml')
    perform_enqueued_jobs do
      te = @task.execute(xml, nil)
      te.reload
      assert_equal 3, te.execution_errors.length, 'should have 1 error for the invalid performance rate'
    end
  end

  def test_should_error_when_measure_period_is_wrong
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_mp.xml', 'text/xml')
    perform_enqueued_jobs do
      te = @task.execute(xml, nil)
      te.reload
      assert_equal 4, te.execution_errors.length, 'should have 2 errors for the invalid reporting period'
    end
  end
end
