# frozen_string_literal: true

require 'test_helper'

class ProductTestSetupJobTest < ActiveJob::TestCase
  def setup
    vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    @product = vendor.products.build(name: 'test_product', c2_test: true, randomize_patients: true, bundle_id: @bundle.id,
                                     measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
  end

  def test_perform_with_measure_test_creates_provider
    test = @product.product_tests.build({ name: "my measure test #{rand}", measure_ids: @product.measure_ids }, MeasureTest)
    ProductTestSetupJob.perform_now(test)
    @product.save!
    test.reload

    assert test.provider
  end

  def test_ipp_result_ignores_nil_calculation_results
    job = ProductTestSetupJob.new

    assert_not job.send(:ipp_result?, [nil])
    assert job.send(:ipp_result?, [nil, CQM::IndividualResult.new(IPP: 1)])
  end

  def test_perform_does_not_delete_patients_when_calculation_returns_no_results
    @product.save!
    test = @product.product_tests.build({ name: "my measure test #{rand}", measure_ids: @product.measure_ids }, MeasureTest)
    test.save!
    test.generate_patients
    patient_count = test.patients.count

    ProductTestSetupJob.any_instance.stubs(:calculate_product_test).returns([nil])
    ProductTestSetupJob.perform_now(test)

    test.reload
    assert_equal :errored, test.state
    assert_equal patient_count, test.patients.count
    assert_match 'Calculation returned no product test results', test.status_message
  end
end
