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

  def setup_product_tests(c1, c2, c3, c4, filters)
    product = @vendor.products.create!(name: 'test_product_name', c1_test: c1, c2_test: c2, c3_test: c3, c4_test: c4,
                                       measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
    @product_test = product.product_tests.build({ name: 'test_measure_test_name', cms_id: 'TEST_CMSID',
                                                  measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    @product_test.generate_provider
    @product_test.save!
    @f_test = product.product_tests.create!({ name: 'test_filtering_test_name', cms_id: 'TEST_CMSID',
                                              measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], options: { filters: filters } }, FilteringTest)
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
    assert_equal get_title_message(@product_test, @product_test.tasks.find_by(_type: 'C1Task')), 'C1 and C3 certifications for TEST_CMSID test_measure_test_name'
    assert_equal get_title_message(@f_test, @f_test.tasks.find_by(_type: 'Cat1FilterTask')), 'CQM Filters Filt1/Filt2 for TEST_CMSID test_filtering_test_name'
  end

  def test_get_title_message_cat3
    setup_product_tests(false, true, false, true, filt1: 'val1')

    assert_equal get_title_message(@product_test, @product_test.tasks.find_by(_type: 'C2Task')), 'C2 certification for TEST_CMSID test_measure_test_name'
    assert_equal get_title_message(@f_test, @f_test.tasks.find_by(_type: 'Cat1FilterTask')), 'CQM Filter Filt1 for TEST_CMSID test_filtering_test_name'
  end

  def test_get_upload_type
    assert_equal 'zip file of QRDA Category I documents', get_upload_type(true)
    assert_equal 'QRDA Category III XML document', get_upload_type(false)
  end

  def test_get_error_counts_no_execution
    setup_product_tests(true, false, true, true, filt1: 'val1')

    errors_hash = get_error_counts(nil, @product_test.tasks.find_by(_type: 'C1Task'))

    assert_equal '--', errors_hash['QRDA Errors']
    assert_equal '--', errors_hash['Reporting Errors']
    assert_equal '--', errors_hash['Submission Errors']
  end

  def test_get_error_counts
    setup_product_tests(true, true, false, true, filt1: 'val1')
    c1_task = @product_test.tasks.find_by(_type: 'C1Task')

    execution = c1_task.test_executions.create!(:user=>@user)
    execution.execution_errors.create(:message => 'qrda error 1', :msg_type => :error, :validator_type => :xml_validation)
    execution.execution_errors.create(:message => 'result error 1', :msg_type => :error, :validator_type => :result_validation)
    execution.execution_errors.create(:message => 'result error 2', :msg_type => :error, :validator_type => :result_validation)
    execution.state = :failed

    errors_hash = get_error_counts(execution, c1_task)

    assert_equal 1, errors_hash['QRDA Errors']
    assert_equal 2, errors_hash['Reporting Errors']
    assert_nil errors_hash['Submission Errors']
  end

  def test_get_select_history_message
    setup_product_tests(true, true, false, true, :filt1 => 'val1')
    execution = @product_test.tasks.find_by(:_type => 'C1Task').test_executions.create!(:user => @user)

    execution.execution_errors.create(:message => 'qrda error 1', :msg_type => :error, :validator_type => :xml_validation)
    execution.execution_errors.create(:message => 'result error 1', :msg_type => :error, :validator_type => :result_validation)
    execution.execution_errors.create(:message => 'result error 2', :msg_type => :error, :validator_type => :result_validation)

    execution.state = :failed
    msg = get_select_history_message(execution, true)

    assert_includes msg, 'Most Recent'
    assert_includes msg, '(3 errors)'

    execution.state = :passed
    msg = get_select_history_message(execution, false)

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
    a = { :file_name => nil }
    b = { :file_name => 'beta' }
    assert_equal 1, compare_error_locations_across_files(a, b)

    a = { :file_name => 'alpha' }
    b = { :file_name => 'beta' }
    assert_equal(-1, compare_error_locations_across_files(a, b))

    a = { :file_name => 'delta', :location => '/div[1]/div[1]/div[2]' }
    b = { :file_name => 'delta', :location => '/div[1]/div[2]/div[1]' }
    assert_equal(-1, compare_error_locations_across_files(a, b))
  end

  def test_info_title_for_product_test
    assert_equal 'Measure Test Information', info_title_for_product_test(MeasureTest.new)
    assert_equal 'Filtering Test Information', info_title_for_product_test(FilteringTest.new)
    assert_equal 'Record Sample Test Information', info_title_for_product_test(ChecklistTest.new)
    assert_equal 'Test Information', info_title_for_product_test(ProductTest.new)
  end

  def test_current_certifications
    # c1 and c2 measure tests
    assert_equal [true, false, false, false], current_certifications('C1Task', false)
    assert_equal [false, true, false, false], current_certifications('C2Task', false)
    assert_equal [true, false, true, false], current_certifications('C1Task', true)
    assert_equal [false, true, true, false], current_certifications('C2Task', true)

    # filtering tests
    assert_equal [false, false, false, true], current_certifications('Cat1FilterTask', false)
    assert_equal [false, false, false, true], current_certifications('Cat1FilterTask', true)
    assert_equal [false, false, false, true], current_certifications('Cat3FilterTask', false)
    assert_equal [false, false, false, true], current_certifications('Cat3FilterTask', true)

    # checklist tests
    assert_equal [true, false, false, false], current_certifications('C1ChecklistTask', false)
    assert_equal [true, false, true, false], current_certifications('C1ChecklistTask', true)
  end

  def test_padding_cms_id
    assert_equal 'CMS002v5', padded_cms_id('CMS2v5')
    assert_equal 'CMS020v5', padded_cms_id('CMS20v5')
    assert_equal 'CMS200v5', padded_cms_id('CMS200v5')
  end
end
