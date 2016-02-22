require 'test_helper'
class C3Cat1TaskTest < ActiveSupport::TestCase
  include ::Validators

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @test = ProductTest.find('51703a883054cf84390000d3')
    @test.product.c3_test = true
    @task = @test.tasks.create({}, C3Cat1Task)
  end

  def test_task_should_include_c3_cat1_validators
    assert @task.validators.count { |v| v.is_a?(MeasurePeriodValidator) } > 0
  end
end
