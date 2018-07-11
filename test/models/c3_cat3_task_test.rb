require 'test_helper'
class C3Cat3TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @test = FactoryBot.create(:product_test_static_result)
    @test.product.c3_test = true
    @test.product.c2_test = true
    @task = @test.tasks.create({}, C3Cat3Task)
  end

  def test_task_should_include_c3_cat3_validators
    assert(@task.validators.any? { |v| v.is_a?(MeasurePeriodValidator) })
  end

  def test_should_cause_error_when_measure_is_not_included_in_report_with_c3
    xml = create_rack_test_file('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_missing_measure.xml', 'text/xml')
    perform_enqueued_jobs do
      te = @task.execute(xml, User.first, nil)
      te.reload
      assert_equal 0, te.execution_errors.length, 'should have no errors for the invalid measure ids, this is a c2 validaton'
    end
  end

  def test_should_cause_error_when_performance_rate_is_incorrect_with_c3
    xml = create_rack_test_file('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_bad_performance_rate.xml', 'text/xml')
    perform_enqueued_jobs do
      te = @task.execute(xml, User.first, nil)
      te.reload
      assert_equal 1, te.execution_errors.length, 'should have 1 error for the invalid performance rate'
      msg = 'Reported Performance Rate of 0.5 for Numerator D285D0D1-0AB5-4228-A5A3-F3DE5952F4AF does not match expected value of 0.0.'
      assert_equal msg, te.execution_errors[0].message
    end
  end

  def test_should_error_when_measure_period_is_wrong
    bundle = @test.bundle
    bundle.measure_period_start = 1_420_070_400
    bundle.effective_date = 1_451_520_000
    bundle.save!
    xml = create_rack_test_file('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_bad_mp.xml', 'text/xml')
    perform_enqueued_jobs do
      te = @task.execute(xml, User.first, nil)
      te.reload
      assert_equal 2, te.execution_errors.length, 'should have 2 errors for the invalid reporting period'
      assert_equal 'Reported Measurement Period should start on 20150101', te.execution_errors[0].message
      assert_equal 'Reported Measurement Period should end on 20151231', te.execution_errors[1].message
    end
  end
end
