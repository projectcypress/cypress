require 'test_helper'
class C3Cat1TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @test = ProductTest.find('51703a883054cf84390000d3')
    @test.product.c3_test = true
    @task = @test.tasks.create({}, C3Cat1Task)
  end

  def test_task_should_include_c3_cat1_validators
    assert @task.validators.any? { |v| v.is_a?(MeasurePeriodValidator) }
  end

  def test_task_should_not_error_when_extra_record_included
    c1_task = @test.tasks.create!({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_extra_file.zip'))
    perform_enqueued_jobs do
      te = @task.execute(zip, User.first, c1_task)
      te.reload
      assert_empty te.execution_errors.where(file_name: '2_Alice_Wise.xml'), 'should be no errors from extra file'
      # expected errors: none
      # in contrast to c1_task_test.test_task_should_error_when_extra_record_included

      # extra record has qrda errors but those should not be validated (in either case)
    end
  end
end
