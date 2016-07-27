require 'test_helper'

class TestExecutionHelper < ActiveSupport::TestCase
  include TestExecutionsHelper
  include ActiveJob::TestHelper

  # # # # # # # # #
  #   S E T U P   #
  # # # # # # # # #

  def setup
    drop_database
    collection_fixtures('product_tests', 'products', 'bundles', 'artifacts',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    load_library_functions
    @vendor = Vendor.create(name: 'test_vendor_name')
  end

  def setup_product_tests(c1, c2, c3, c4, filters)
    product = @vendor.products.create!(name: 'test_product_name', c1_test: c1, c2_test: c2, c3_test: c3, c4_test: c4,
                                       measure_ids: ['40280381-43DB-D64C-0144-5571970A2685'], bundle_id: '4fdb62e01d41c820f6000001')
    @m_test = product.product_tests.create!({ name: 'test_measure_test_name', cms_id: 'TEST_CMSID',
                                              measure_ids: ['40280381-43DB-D64C-0144-5571970A2685'] }, MeasureTest)
    @f_test = product.product_tests.create!({ name: 'test_filtering_test_name', cms_id: 'TEST_CMSID',
                                              measure_ids: ['40280381-43DB-D64C-0144-5571970A2685'], options: { filters: filters } }, FilteringTest)
  end

  # # # # # # # # #
  #   T E S T S   #
  # # # # # # # # #

  def test_displaying_cat1
    setup_product_tests(true, true, false, true, filt1: 'val1')

    assert displaying_cat1?(@m_test.tasks.find_by(_type: 'C1Task'))
    assert displaying_cat1?(@f_test.tasks.find_by(_type: 'Cat1FilterTask'))

    assert_equal false, displaying_cat1?(@m_test.tasks.find_by(_type: 'C2Task'))
    assert_equal false, displaying_cat1?(@f_test.tasks.find_by(_type: 'Cat3FilterTask'))
  end

  def test_get_title_message_cat1_singlular
    setup_product_tests(true, false, false, true, filt1: 'val1')

    assert_equal get_title_message(@m_test, @m_test.tasks.find_by(_type: 'C1Task')), 'C1 certification for TEST_CMSID test_measure_test_name'
    assert_equal get_title_message(@f_test, @f_test.tasks.find_by(_type: 'Cat1FilterTask')), 'CQM Filter Filt1 for TEST_CMSID test_filtering_test_name'
  end

  def test_get_title_message_cat1_plural
    setup_product_tests(true, false, true, true, filt1: 'val1', filt2: 'val2')

    assert_equal get_title_message(@m_test, @m_test.tasks.find_by(_type: 'C1Task')), 'C1 and C3 certifications for TEST_CMSID test_measure_test_name'
    assert_equal get_title_message(@f_test, @f_test.tasks.find_by(_type: 'Cat1FilterTask')), 'CQM Filters Filt1/Filt2 for TEST_CMSID test_filtering_test_name'
  end

  def test_get_title_message_cat3
    setup_product_tests(false, true, false, true, filt1: 'val1')

    assert_equal get_title_message(@m_test, @m_test.tasks.find_by(_type: 'C2Task')), 'C2 certification for TEST_CMSID test_measure_test_name'
    assert_equal get_title_message(@f_test, @f_test.tasks.find_by(_type: 'Cat1FilterTask')), 'CQM Filter Filt1 for TEST_CMSID test_filtering_test_name'
  end

  def test_get_upload_type
    assert_equal 'zip file of QRDA Category I documents', get_upload_type(true)
    assert_equal 'QRDA Category III XML document', get_upload_type(false)
  end

  def test_get_error_counts_no_execution
    setup_product_tests(true, false, true, true, filt1: 'val1')
    errors_hash = get_error_counts(false, @m_test.tasks.find_by(_type: 'C1Task'))

    assert_equal '--', errors_hash['QRDA Errors']
    assert_equal '--', errors_hash['Reporting Errors']
    assert_equal '--', errors_hash['Submission Errors']
  end

  def test_get_error_counts
    setup_product_tests(true, true, false, true, filt1: 'val1')
    c1_task = @m_test.tasks.find_by(_type: 'C1Task')

    execution = c1_task.test_executions.create
    execution.execution_errors.create(:message => 'qrda error 1', :msg_type => :error, :validator_type => :xml_validation)
    execution.execution_errors.create(:message => 'result error 1', :msg_type => :error, :validator_type => :result_validation)
    execution.execution_errors.create(:message => 'result error 2', :msg_type => :error, :validator_type => :result_validation)
    execution.state = :failed

    errors_hash = get_error_counts(execution, c1_task)

    assert_equal 1, errors_hash['QRDA Errors']
    assert_equal 2, errors_hash['Reporting Errors']
    assert_equal nil, errors_hash['Submission Errors']
  end

  def test_get_select_history_message
    setup_product_tests(true, true, false, true, filt1: 'val1')
    execution = @m_test.tasks.find_by(_type: 'C1Task').test_executions.create

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
    assert_equal 'Measure Test Information', info_title_for_product_test(MeasureTest.new)
    assert_equal 'Filtering Test Information', info_title_for_product_test(FilteringTest.new)
    assert_equal 'Manual Entry Test Information', info_title_for_product_test(ChecklistTest.new)
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
    assert_equal [true, false, false, false], current_certifications('C1ManualTask', false)
    assert_equal [true, false, true, false], current_certifications('C1ManualTask', true)
  end
end
