# frozen_string_literal: true

require 'test_helper'

class TestExecutionHelper < ActiveSupport::TestCase
  include TestExecutionsHelper
  include ApplicationHelper
  include ActiveJob::TestHelper

  # # # # # # # # #
  #   S E T U P   #
  # # # # # # # # #

  def setup
    @bundle = FactoryBot.create(:static_bundle)
    @user = FactoryBot.create(:vendor_user)
    @vendor = Vendor.create!(name: 'test_vendor_name')
    @errors = []
    @errors << { message: 'pop_error',
                 error_details: { 'population_id' => 'IPP', 'stratification' => false, 'type' => 'population' } }
    @errors << { message: 'strat_error',
                 error_details: { 'population_id' => 'IPP', 'stratification' => true, 'type' => 'population' } }
    @errors << { message: 'not correct',
                 error_details: { 'population_id' => 'IPOP', 'stratification' => false, 'type' => 'population' } }
    @errors << { message: 'pop_sum_error',
                 error_details: { 'population_id' => 'IPP', 'stratification' => false, 'type' => 'population_sum' } }
    @errors << { message: 'sup_error',
                 error_details: { 'population_id' => 'IPP', 'stratification' => false, 'type' => 'supplemental_data' } }
  end

  def setup_product_tests(c1_test, c2_test, c3_test, c4_test, filters)
    product = @vendor.products.create!(name: 'test_product_name', c1_test:, c2_test:, c3_test:, c4_test:,
                                       measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    @product_test = product.product_tests.build({ name: 'test_measure_test_name', cms_id: 'TEST_CMSID',
                                                  measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    @product_test.save!
    @f_test = product.product_tests.create!({ name: 'test_filtering_test_name', cms_id: 'TEST_CMSID',
                                              measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], options: { filters: } }, FilteringTest)
  end

  # # # # # # # # #
  #   T E S T S   #
  # # # # # # # # #

  def test_displaying_cat1
    setup_product_tests(true, true, false, true, filt1: 'val1')

    assert displaying_cat1?(@product_test.tasks.find_by(_type: 'C1Task'))
    assert displaying_cat1?(@f_test.tasks.find_by(_type: 'Cat1FilterTask'))

    assert_equal false, displaying_cat1?(@product_test.tasks.find_by(_type: 'C2Task'))
    assert_equal false, displaying_cat1?(@f_test.tasks.find_by(_type: 'Cat3FilterTask'))
  end

  def test_get_title_message_cat1_singlular
    setup_product_tests(true, false, false, true, filt1: 'val1')

    assert_equal get_title_message(@product_test, @product_test.tasks.find_by(_type: 'C1Task')), 'C1 certification for TEST_CMSID test_measure_test_name'
    assert_equal get_title_message(@f_test, @f_test.tasks.find_by(_type: 'Cat1FilterTask')), 'CQM Filter Filt1 for TEST_CMSID test_filtering_test_name'
  end

  def test_get_title_message_cat1_plural
    setup_product_tests(true, false, true, true, filt1: 'val1', filt2: 'val2')
    measure = @product_test.measures.first
    measure.reporting_program_type = 'eh'
    measure.save
    @product_test.reload
    assert_equal get_title_message(@product_test, @product_test.tasks.find_by(_type: 'C1Task')), 'C1 and C3 certifications for TEST_CMSID test_measure_test_name'
    assert_equal get_title_message(@f_test, @f_test.tasks.find_by(_type: 'Cat1FilterTask')), 'CQM Filters Filt1/Filt2 for TEST_CMSID test_filtering_test_name'
  end

  def test_get_title_message_cat3
    setup_product_tests(false, true, false, true, filt1: 'val1')

    assert_equal get_title_message(@product_test, @product_test.tasks.find_by(_type: 'C2Task')), 'C2 certification for TEST_CMSID test_measure_test_name'
    assert_equal get_title_message(@f_test, @f_test.tasks.find_by(_type: 'Cat1FilterTask')), 'CQM Filter Filt1 for TEST_CMSID test_filtering_test_name'
  end

  def test_get_upload_type
    assert_equal 'zip file of QRDA Category I (STU 5.3) documents', get_upload_type(true, @bundle)
    assert_equal 'QRDA Category III (R1) XML document', get_upload_type(false, @bundle)
  end

  def test_get_error_counts_no_execution
    setup_product_tests(true, false, true, true, filt1: 'val1')

    errors_hash = get_error_counts(nil)

    assert_equal '--', errors_hash['Errors']
    assert_equal '--', errors_hash['Warnings']
  end

  def test_get_error_counts
    setup_product_tests(true, true, false, true, filt1: 'val1')
    c1_task = @product_test.tasks.find_by(_type: 'C1Task')

    execution = c1_task.test_executions.create!(user: @user)
    execution.execution_errors.create(message: 'qrda error 1', msg_type: :error, validator_type: :xml_validation)
    execution.execution_errors.create(message: 'result error 1', msg_type: :error, validator_type: :result_validation)
    execution.execution_errors.create(message: 'result error 2', msg_type: :error, validator_type: :result_validation)
    execution.state = :failed

    errors_hash = get_error_counts(execution)

    assert_equal 3, errors_hash['Errors']
  end

  def test_get_select_history_message
    setup_product_tests(true, true, false, true, filt1: 'val1')
    execution = @product_test.tasks.find_by(_type: 'C1Task').test_executions.create!(user: @user)

    execution.execution_errors.create(message: 'qrda error 1', msg_type: :error, validator_type: :xml_validation)
    execution.execution_errors.create(message: 'result error 1', msg_type: :error, validator_type: :result_validation)
    execution.execution_errors.create(message: 'result error 2', msg_type: :error, validator_type: :result_validation)

    execution.state = :failed
    msg = get_select_history_message(execution, 0, 1)

    assert_includes msg, 'Most Recent'
    assert_includes msg, '(3 errors)'

    execution.state = :passed
    msg = get_select_history_message(execution, 1, 1)

    assert_not_includes msg, 'Most Recent'
    assert_includes msg, '(passing)'
  end

  def test_population_errors
    pop_errors = population_errors(@errors, 'IPP')

    assert_equal 1, pop_errors.length
    assert_equal 'pop_error', pop_errors[0].message
  end

  def test_stratification_errors
    strat_errors = stratification_errors(@errors, 'IPP')

    assert_equal 1, strat_errors.length
    assert_equal 'strat_error', strat_errors[0].message
  end

  def test_pop_sum_errors
    psum_errors = pop_sum_errors(@errors, 'IPP')

    assert_equal 1, psum_errors.length
    assert_equal 'pop_sum_error', psum_errors[0].message
  end

  def test_supplemental_errors
    sup_errors = supplemental_errors(@errors, 'IPP')

    assert_equal 1, sup_errors.length
    assert_equal 'sup_error', sup_errors[0].message
  end

  # -1 is first before second
  #  1 is second before first
  def test_compare_error_locations_across_files
    a = { file_name: nil }
    b = { file_name: 'beta' }
    assert_equal 1, compare_error_locations_across_files(a, b)

    a = { file_name: 'alpha' }
    b = { file_name: 'beta' }
    assert_equal(-1, compare_error_locations_across_files(a, b))

    a = { file_name: 'delta', location: '/div[1]/div[1]/div[2]' }
    b = { file_name: 'delta', location: '/div[1]/div[2]/div[1]' }
    assert_equal(-1, compare_error_locations_across_files(a, b))
  end

  def test_info_title_for_product_test
    assert_equal 'CMS123 Measure Test', info_title_for_product_test(MeasureTest.new(cms_id: 'CMS123'))
    assert_equal 'CMS123 Filtering Test', info_title_for_product_test(FilteringTest.new(cms_id: 'CMS123'))
    assert_equal 'Record Sample Test Information', info_title_for_product_test(ChecklistTest.new)
    assert_equal 'EH Measures Test', info_title_for_product_test(MultiMeasureTest.new(reporting_program_type: 'eh'))
    assert_equal 'EP/EC Measures Test', info_title_for_product_test(MultiMeasureTest.new(reporting_program_type: 'ep'))
    assert_equal 'Test Information', info_title_for_product_test(ProductTest.new)
  end

  def test_current_certifications
    # c1 and c2 measure tests
    assert_equal [true, false, false, false], current_certifications('C1Task', false, true, false)
    assert_equal [false, true, false, false], current_certifications('C2Task', false, true, false)
    assert_equal [true, false, true, false], current_certifications('C1Task', true, true, false)
    assert_equal [false, true, true, false], current_certifications('C2Task', true, false, true)

    # filtering tests
    assert_equal [false, false, false, true], current_certifications('Cat1FilterTask', false, true, false)
    assert_equal [false, false, false, true], current_certifications('Cat1FilterTask', true, true, false)
    assert_equal [false, false, false, true], current_certifications('Cat3FilterTask', false, true, false)
    assert_equal [false, false, false, true], current_certifications('Cat3FilterTask', true, true, false)

    # checklist tests
    assert_equal [true, false, false, false], current_certifications('C1ChecklistTask', false, false, true)
    assert_equal [true, false, true, false], current_certifications('C1ChecklistTask', true, true, false)
  end

  def test_padding_cms_id
    assert_equal 'CMS0002v5', padded_cms_id('CMS2v5')
    assert_equal 'CMS0020v5', padded_cms_id('CMS20v5')
    assert_equal 'CMS0200v5', padded_cms_id('CMS200v5')
    assert_equal 'CMS2000v5', padded_cms_id('CMS2000v5')
  end

  def test_ecqi_link
    # test with a measure from the 2023 reporting period
    bundle2022 = Bundle.create(version: '2022.5.0')
    measure2022 = Measure.create(reporting_program_type: 'ep', cms_id: 'CMS161v11', bundle_id: bundle2022.id)
    ecqi_url2022 = ecqi_link(measure2022.cms_id)
    ecqi_request2022 = RestClient::Request.execute(method: :get, url: ecqi_url2022)
    assert_equal 200, ecqi_request2022.code
  end
end
