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
    @test.product.c2_test = true
    @task = @test.tasks.create({}, C3Cat3Task)
    @bundle = Bundle.find('4fdb62e01d41c820f6000001')
    @bundle.measure_period_start = 1_420_070_400
    @bundle.effective_date = 1_451_520_000
    @bundle.save!
  end

  def test_task_should_include_c3_cat3_validators
    assert(@task.validators.any? { |v| v.is_a?(MeasurePeriodValidator) })
  end

  def test_should_cause_error_when_measure_is_not_included_in_report_with_c3
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_missing_measure.xml', 'text/xml')
    perform_enqueued_jobs do
      te = @task.execute(xml, User.first, nil)
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
      te = @task.execute(xml, User.first, nil)
      te.reload
      assert te.execution_errors.length > 1, 'should have 1 error for the invalid performance rate'
      msg = 'Reported Performance Rate of 0.833 for Numerator E60D324E-7606-42C2-8E46-5EE29289725D does not match expected value of 0.333333.'
      assert_equal msg, te.execution_errors[0].message
    end
  end

  def test_should_error_when_measure_period_is_wrong
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_mp.xml', 'text/xml')
    perform_enqueued_jobs do
      te = @task.execute(xml, User.first, nil)
      te.reload
      assert te.execution_errors.length > 2, 'should have 2 errors for the invalid reporting period'
      assert_equal 'Reported Measurement Period should start on 20150101', te.execution_errors[0].message
      assert_equal 'Reported Measurement Period should end on 20151231', te.execution_errors[1].message
    end
  end
end
