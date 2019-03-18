require 'test_helper'
class MultiMeasureTestTest < ActiveJob::TestCase
  def setup
    @vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
  end

  def setup_extra_measures
    cloned_cv = Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first.clone
    cloned_proportion = Measure.where(hqmf_id: '40280382-5FA6-FE85-0160-0918E74D2075').first.clone
    cloned_cv.hqmf_id = 'AE65090C-EB1F-11E7-8C3F-9A214CF093AE'
    cloned_cv.reporting_program_type = 'eh'
    cloned_cv.save
    cloned_proportion.hqmf_id = '50280382-5FA6-FE85-0160-0918E74D2075'
    cloned_proportion.reporting_program_type = 'eh'
    cloned_proportion.save
  end

  def test_multi_measure_test_creation_with_two_ep
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE', '40280382-5FA6-FE85-0160-0918E74D2075']
    product = @vendor.products.create(name: "my product #{rand}", cvuplus: true, randomize_patients: true, duplicate_patients: true,
                                      bundle_id: @bundle.id)

    params = { measure_ids: measure_ids, 'cvuplus' => 'true' }
    product.update_with_tests(params)
    assert_equal true, product.save, 'should save with two measure ids'
    assert_equal 1, product.product_tests.size, 'should have with one product test'
    assert_equal 'MultiMeasureTest', product.product_tests.first._type, 'should be a mutli measure test'
  end

  def test_multi_measure_test_creation_with_two_ep_two_eh
    setup_extra_measures
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE',
                   '40280382-5FA6-FE85-0160-0918E74D2075',
                   'AE65090C-EB1F-11E7-8C3F-9A214CF093AE',
                   '50280382-5FA6-FE85-0160-0918E74D2075']
    product = @vendor.products.create(name: "my product #{rand}", cvuplus: true, randomize_patients: true, duplicate_patients: true,
                                      bundle_id: @bundle.id)

    params = { measure_ids: measure_ids, 'cvuplus' => 'true' }
    product.update_with_tests(params)
    assert_equal 2, product.product_tests.size, 'should have with two product test'
    ep_measure_test = product.product_tests.where(name: 'EP Measures').first
    eh_measure_test = product.product_tests.where(name: 'EH Measures').first
    assert_equal 'MultiMeasureCat3Task', ep_measure_test.tasks.first._type, 'an ep multi measure test should have a cat 3 task'
    assert_equal 'MultiMeasureCat1Task', eh_measure_test.tasks.first._type, 'an eh multi measure test should have a cat 1 task'
    assert_equal 2, ep_measure_test.measures.size, 'the ep multi measure test should be for 2 measures'
    assert_equal 1, ep_measure_test.tasks.size, 'a multi measure test (ep or eh) should only have a single task'
  end
end
