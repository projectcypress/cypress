# frozen_string_literal: true

require 'test_helper'
require 'helpers/caching_test'

class ProducTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @bundle = FactoryBot.create(:static_bundle)
    @vendor = FactoryBot.create(:vendor)
    @vendor_user = FactoryBot.create(:vendor_user)
    ActionController::Base.perform_caching = true
    @old_cache_store = ActionController::Base.cache_store
    ActionController::Base.cache_store = :memory_store, { size: 64.megabytes }
    Rails.cache.clear
  end

  def teardown
    ActionController::Base.perform_caching = false
    ActionController::Base.cache_store = @old_cache_store
    drop_database
  end

  def test_create_2015_certification_no_c2
    pt = Product.new(vendor: @vendor, name: 'test_product', c1_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id).save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
    assert_equal true, pt.randomize_patients
    assert_equal false, pt.duplicate_patients
  end

  def test_create_2015_certification_with_c2
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id).save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
    assert_equal true, pt.randomize_patients
    assert_equal true, pt.duplicate_patients
  end

  def test_offset
    pt = Product.new(vendor: @vendor, name: 'test_product', c1_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                     bundle_id: @bundle.id, shift_patients: true)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id).save!
    # Test that start dates (bundle and shifted) are the same (and a year apart)
    assert_equal Time.zone.at(pt.measure_period_start).min, Time.zone.at(pt.bundle.measure_period_start).min
    assert_equal Time.zone.at(pt.measure_period_start).hour, Time.zone.at(pt.bundle.measure_period_start).hour
    assert_equal Time.zone.at(pt.measure_period_start).day, Time.zone.at(pt.bundle.measure_period_start).day
    assert_equal Time.zone.at(pt.measure_period_start).month, Time.zone.at(pt.bundle.measure_period_start).month
    assert_equal Time.zone.at(pt.measure_period_start).year, Time.zone.at(pt.bundle.measure_period_start).year + 2
    # Test that shifted effective time is the last minute of the same year as the measure period start
    assert_equal Time.zone.at(pt.effective_date).year, Time.zone.at(pt.effective_date).year
    assert_equal Time.zone.at(pt.effective_date).min, 59
    assert_equal Time.zone.at(pt.effective_date).hour, 23
    assert_equal Time.zone.at(pt.effective_date).day, 31
    assert_equal Time.zone.at(pt.effective_date).month, 12
  end

  def test_create_from_vendor
    pt = @vendor.products.build(name: 'test_product', c1_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id).save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save a Product'
  end

  def test_must_have_name
    pt = Product.new(vendor: @vendor, c1_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id)
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without a name'
  end

  def test_must_have_vendor
    pt = Product.new(name: 'test_product', c1_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id)
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without a vendor'
  end

  def test_must_have_at_least_one_certification_test_type
    pt = Product.new(vendor: @vendor, name: 'test_product', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id)
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without at least one certification type'
  end

  def test_must_certify_to_c1_or_c2_or_c3_or_c4
    pt = Product.new(vendor: @vendor, name: 'test_product', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id)
    assert_equal false, pt.valid?, 'record should not be valid'
    saved = pt.save
    assert_equal false, saved, 'Should not be able to save without C1, C2, C3, or C4'
  end

  def test_can_have_multiple_certification_test_types
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id).save!
    assert pt.valid?, 'record should be valid'
    assert pt.save, 'Should be able to create and save with two certification types'
  end

  def test_measure_tests
    pt = Product.new(vendor: @vendor, name: 'measure_test', c1_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build({ name: 'test_product_test_name',
                             measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                             bundle_id: @bundle.id }, MeasureTest)
    pt.save!
    assert pt.product_tests.measure_tests
    assert_equal pt.product_tests.measure_tests.count, 1
  end

  def test_no_checklist_test
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build(name: 'test_product_test_name',
                           measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                           bundle_id: @bundle.id).save!
    assert_not pt.product_tests.checklist_tests.exists?
  end

  def test_create_checklist_test
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    pt.product_tests.build({ name: 'test_checklist_test',
                             measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                             bundle_id: @bundle.id }, ChecklistTest).save!
    assert pt.product_tests.checklist_tests.exists?
  end

  def test_update_with_measure_tests_creates_measure_tests_if_c2_selected
    measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    product = @vendor.products.new
    product.name = 'test name'
    product.bundle = @bundle
    params = { vendor: @vendor, name: "my product #{rand}", c2_test: '1', measure_ids:, bundle_id: @bundle.id }
    # This fails because there is no provider when update is called through this function
    # TODO: either provide provider, or generate in the called method
    product.update_with_tests(params)
    assert_equal measure_ids.count, product.product_tests.measure_tests.count
    assert_equal measure_ids.first, product.product_tests.measure_tests.first.measure_ids.first
    assert_equal 0, product.product_tests.checklist_tests.count
  end

  def test_add_filtering_tests
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                     bundle_id: @bundle.id)
    pt.save!
    perform_enqueued_jobs do
      FilterTestSetupJob.perform_now(pt.id.to_s)
    end
    assert_equal 5, pt.product_tests.filtering_tests.count
  end

  def test_add_filtering_test_without_snomed_dx
    # Modify a measure to have a single Diagnosis data criteria without a snomed code
    measure = Measure.find_by hqmf_id: '40280382-5FA6-FE85-0160-0918E74D2075'
    vs = ValueSet.first
    vs.concepts.first.code_system_oid = '2.16.840.1.113883.6.95' # Not SNOMED
    vs.save
    measure.source_data_criteria = [QDM::Diagnosis.new(codeListId: vs.oid)]
    measure.save
    pt = Product.new(vendor: @vendor, name: 'test_product', c2_test: true, c4_test: true, measure_ids: ['40280382-5FA6-FE85-0160-0918E74D2075'],
                     bundle_id: @bundle.id)
    pt.save!
    perform_enqueued_jobs do
      FilterTestSetupJob.perform_now(pt.id.to_s)
    end
    filter_criteria = pt.product_tests.filtering_tests.collect(&:options).collect(&:filters).collect(&:keys).flatten
    # The set of filter_criteria should not include a problem filter
    assert_equal false, filter_criteria.include?('problems')
  end

  # def test_add_checklist_test
  #   pt = Product.new(vendor: @vendor, name: 'my_product', c1_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
  #                    bundle_id: @bundle.id)
  #   pt.product_tests.build({ name: 'first measure test', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
  #   pt.save!
  #   pt.add_checklist_test
  #   assert pt.product_tests.checklist_tests.count > 0
  #   assert pt.product_tests.checklist_tests.first.measure_ids.include? 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'

  #   # test if old product test can be deleted (since measure with id ending in 1C39 was removed) and new checklist test created
  #   pt.product_tests.destroy { |test| test }
  #   pt.product_tests.build({ name: 'second measure test', measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'] }, MeasureTest)
  #   pt.measure_ids = ['40280381-4B9A-3825-014B-C1A59E160733']
  #   pt.save!
  #   pt.add_checklist_test
  #   assert pt.product_tests.checklist_tests.count > 0
  #   assert pt.product_tests.checklist_tests.first.measure_ids.include? '40280381-4B9A-3825-014B-C1A59E160733'

  #   # test checklist tests should not change if new measures are added to product
  #   old_checklist_test = pt.product_tests.checklist_tests.first
  #   pt.product_tests.build({ name: 'third measure test', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
  #   pt.save!
  #   pt.add_checklist_test
  #   assert pt.product_tests.checklist_tests.first == old_checklist_test
  # end

  def test_add_checklist_test_adds_tests_and_tasks_if_appropriate
    measure_id = 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'
    product = @vendor.products.create!(name: "my product #{rand}", measure_ids: [measure_id], c2_test: true, bundle_id: @bundle.id)
    product.product_tests.create!({ name: "my measure test #{rand}", measure_ids: [measure_id] }, MeasureTest)
    # should create no product tests if c1 was not selected
    product.add_checklist_test
    assert_equal 0, product.product_tests.checklist_tests.count

    # should create only a c1_checklist_task if only c1 and not c3 is selected
    product.update(c1_test: true)
    product.add_checklist_test
    assert_equal 1, product.product_tests.checklist_tests.count
    assert_equal 1, product.product_tests.checklist_tests.first.tasks.count
    assert_equal C1ChecklistTask, product.product_tests.checklist_tests.first.tasks.first.class

    product.product_tests.checklist_tests.each(&:destroy)
    assert_equal 0, product.product_tests.checklist_tests.count

    # should create c1_checklist_task and c3_checklist_task if both c1 and c3 are selected
    product.update(c3_test: true)
    product.add_checklist_test
    assert_equal 1, product.product_tests.checklist_tests.count
    assert_equal 2, product.product_tests.checklist_tests.first.tasks.count

    checklist_tasks = product.product_tests.checklist_tests.first.tasks
    assert arrays_equivalent(checklist_tasks.collect(&:class), [C1ChecklistTask, C3ChecklistTask])
  end

  def test_creates_product_tests_with_vendor_patients
    exec_bundle = FactoryBot.create(:executable_bundle)
    vendor_patient = FactoryBot.create(:vendor_test_patient, bundleId: exec_bundle.id, correlation_id: @vendor.id)
    product = Product.new(vendor: @vendor, name: 'test_product', vendor_patients: true, bundle_patients: false, cvuplus: true, measure_ids: ['40280382-5FA6-FE85-0160-0918E74D2075'], bundle_id: exec_bundle.id, randomize_patients: false)
    params = { 'cvuplus' => 'true', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }
    product.update_with_tests(params)
    # we want to see if this set of patients includes a patient whose whose original_patient_id field matches our patient.id
    # original_patient_id is the ID of the template
    product.product_tests.multi_measure_tests.each do |pt|
      pt.patients.each { |pat| assert_equals pat.original_patient_id, vendor_patient.id }
    end
  end

  def test_creates_product_tests_with_vendor_patients_and_bundle_patients
    perform_enqueued_jobs do
      exec_bundle = FactoryBot.create(:executable_bundle)
      vendor_patient = FactoryBot.create(:vendor_test_patient, bundleId: exec_bundle.id, correlation_id: @vendor.id)
      product = Product.new(vendor: @vendor, name: 'test_product', vendor_patients: true, bundle_patients: true, cvuplus: true, measure_ids: ['40280382-5FA6-FE85-0160-0918E74D2075'], bundle_id: exec_bundle.id, randomize_patients: false)
      params = { 'cvuplus' => 'true', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }
      product.update_with_tests(params)
      exec_ids = exec_bundle.patients.pluck(:_id)
      product.product_tests.multi_measure_tests.each do |pt|
        assert_equal 1, pt.send(:patients_in_ipp_and_greater).size
        assert_equal 0, pt.send(:patients_in_high_value_populations).size
        assert(pt.patients.any? { |pat| pat.original_patient_id == vendor_patient.id })
        pt.patients.each do |pat|
          # if it's not a vendor patient, we want to make sure it's a bundle patient
          assert exec_ids.include? pat.original_patient_id if pat.original_patient_id != vendor_patient.id
        end
      end
    end
  end

  # def test_add_checklist_test_adds_correct_number_of_measures_for_checked_criteria
  #   measure_ids = ['40280381-4B9A-3825-014B-C1A59E160733', 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
  #   product = @vendor.products.create!(name: "my product #{rand}", measure_ids: measure_ids, c1_test: true, bundle_id: @bundle.id)
  #   CAT1_CONFIG['number_of_checklist_measures'] = 1

  #   # create measure tests for each of the measure ids
  #   product.measure_ids.each do |measure_id|
  #     product.product_tests.create!({ name: "measure test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
  #   end

  #   # should only create checked criteria for a single measure
  #   product.add_checklist_test
  #   assert_equal 1, product.product_tests.checklist_tests.count
  #   assert_equal 1, product.product_tests.checklist_tests.first.measures.count

  #   # remove all measure tests so creating checked criteria will use all measures
  #   # also remove all checklist tests
  #   product.product_tests.each(&:destroy)
  # end

  def test_cvu_plus_not_slim
    cvu_product = @vendor.products.create(name: 'test_product_cvu_random', cvuplus: true, randomize_patients: true,
                                          bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    assert_not cvu_product.slim_test_deck?
  end

  def test_c1_slim
    c1_product = @vendor.products.create(name: 'test_product_c1_random', c1_test: true, randomize_patients: true,
                                         bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    assert c1_product.slim_test_deck?
  end

  def test_c1_c2_not_slim
    c1_c2_product = @vendor.products.create(name: 'test_product_c1_c2_random', c1_test: true, c2_test: true, randomize_patients: true,
                                            bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    assert_not c1_c2_product.slim_test_deck?
  end

  # # # # # # # # # # # # # # # #
  #   S T A T U S   T E S T S   #
  # # # # # # # # # # # # # # # #

  def test_product_status
    product = Product.new(vendor: @vendor, name: 'my product', c1_test: true, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    product.save!
    product_test = product.product_tests.build({ name: 'my product test 1', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    product_test.save!
    # status should be incomplete if all product tests passing but no checklist test exists
    product_test.tasks.first.test_executions.create!(state: :passed, user: @vendor_user)
    assert_equal 'incomplete', product.status

    # if product does not need to certify for c1, than product should pass
    product.update(c1_test: nil, c2_test: true)
    assert_equal 'passing', product.status
    product.update(c1_test: true, c2_test: nil)

    # adding a complete checklist test will make product pass
    create_complete_checklist_test_for_product(product, product.measure_ids.first)
    assert_equal 'passing', product.status

    # one failing product test will fail the product
    product_test = product.product_tests.build({ name: 'my product test 2', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    product_test.save!
    te = product_test.tasks.first.test_executions.build(state: :failed)
    @vendor_user.test_executions << te
    te.save!
    assert_equal 'failing', product.status
  end

  def test_product_status_failing_if_one_product_test_are_fails
    measure_id = 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'
    product = Product.new(vendor: @vendor, name: 'my product', c1_test: true, measure_ids: [measure_id], bundle_id: @bundle.id)
    product_test = product.product_tests.build({ name: "my product test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
    product_test.save!
    product_test.tasks.first.test_executions.build(state: :passed, user: @vendor_user)
    product_test.save!
    product.save!
  end

  def create_complete_checklist_test_for_product(product, measure_id)
    # id_of_measure is _id attribute on measure. checked_criteria use this mongoid id as a unique identifier for measures to avoid submeasures
    id_of_measure = Measure.where(hqmf_id: measure_id, bundle_id: product.bundle_id).first.id
    criterias = [ChecklistSourceDataCriteria.new(code: 'my code', attribute_code: 'my attribute code', recorded_result: 'my recorded result',
                                                 code_complete: true, attribute_complete: true, result_complete: true,
                                                 passed_qrda: true, measure_id: id_of_measure)]
    checklist_test = product.product_tests.build({ name: 'my checklist test', checked_criteria: criterias,
                                                   measure_ids: [measure_id] }, ChecklistTest)
    checklist_test.save!
  end
end

class ProductCachingTest < CachingTest
  def test_product_status_and_product_test_groups_are_not_cached_on_start
    assert_not Rails.cache.exist?("#{@product.cache_key}/status"), 'cache key for product status should not exist'
  end

  def test_product_status_is_cached_after_checking_status
    @product.status
    assert Rails.cache.exist?("#{@product.cache_key}/status"), 'cache key for product status should exist'
  end
end
