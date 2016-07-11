require 'test_helper'

class C3ManualTaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')

    vendor = Vendor.create!(name: "my vendor #{rand}")
    product = vendor.products.create!(name: "my product #{rand}", c1_test: true, c3_test: true,
                                      bundle_id: '4fdb62e01d41c820f6000001', measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'])
    checklist_test = product.product_tests.build({ name: 'c1 visual', measure_ids: product.measure_ids }, ChecklistTest)
    checklist_test.save!
    checklist_test.create_checked_criteria
    simplify_criteria(checklist_test)
    @task = checklist_test.tasks.create!({}, C3ManualTask)
  end

  def test_validators_exist
    validators = [MeasurePeriodValidator, QrdaCat1Validator]
    assert (validators - @task.validators.collect(&:class)).empty?
  end

  # TODO: add tests for good and bad test executions

  def simplify_criteria(checklist_test)
    criteria = checklist_test.checked_criteria[0, 2]
    criteria[0].source_data_criteria = 'DiagnosisActiveMajorDepressionIncludingRemission_precondition_40'
    criteria[0].code = '14183003'
    criteria[0].code_complete = true
    criteria[0].attribute_code = '63161005'
    criteria[0].attribute_complete = true
    criteria[1].source_data_criteria = 'PatientCharacteristicEthnicityEthnicity'
    criteria[1].code = '2186-5'
    criteria[1].code_complete = true
    checklist_test.checked_criteria = criteria
    checklist_test.save!
  end
end
