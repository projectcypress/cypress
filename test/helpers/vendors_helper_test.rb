require 'test_helper'

class VendorsHelperTest < ActiveJob::TestCase
  include VendorsHelper
  include ProductsHelper

  def setup
    drop_database
    collection_fixtures('records', 'measures', 'vendors', 'products', 'product_tests', 'bundles')

    @product = Product.new(vendor: Vendor.all.first, name: 'test_product', c1_test: true, c2_test: true, c3_test: true, c4_test: true)

    setup_checklist_test
    setup_measure_tests
    setup_filtering_tests
  end

  def setup_checklist_test
    checklist_test = @product.product_tests.build({ name: 'c1 visual', measure_ids: ['40280381-43DB-D64C-0144-5571970A2685'],
                                                    bundle_id: '4fdb62e01d41c820f6000001' }, ChecklistTest)
    checklist_test.save!
    checked_criterias = []
    measures = Measure.top_level.where(:hqmf_id.in => checklist_test.measure_ids)
    measures.each do |measure|
      # chose criteria randomly
      criterias = measure['hqmf_document']['source_data_criteria'].sort_by { rand }.first(5)
      criterias.each do |criteria_key, _criteria_value|
        checked_criterias.push(measure_id: measure.id.to_s, source_data_criteria: criteria_key, completed: false)
      end
    end
    checklist_test.checked_criteria = checked_criterias
    checklist_test.save!
  end

  def setup_measure_tests
    @product.product_tests.build({ name: 'test_product_test_name_1',
                                   measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'],
                                   bundle_id: '4fdb62e01d41c820f6000001'
                                 }, MeasureTest).save!
    @product.product_tests.build({ name: 'test_product_test_name_2',
                                   measure_ids: ['8A4D92B2-3887-5DF3-0139-11B262260A92'],
                                   bundle_id: '4fdb62e01d41c820f6000001'
                                 }, MeasureTest).save!
    @product.product_tests.measure_tests.each do |test|
      test.tasks.build({}, C1Task)
      test.tasks.build({}, C2Task)
      test.tasks.build({}, C3Task)
    end

    setup_measure_executions
  end

  def setup_measure_executions
    # one C1 failing test, one C3 passing test
    c1_cat1_execution = @product.product_tests.measure_tests.first.c1_task.test_executions.build(:state => :failed)
    c3_cat1_execution = @product.product_tests.measure_tests.first.c3_task.test_executions.build(:state => :passed)
    c1_cat1_execution.sibling_execution_id = c3_cat1_execution.id
    c1_cat1_execution.save
    c3_cat1_execution.save

    # one C2 passing test, one C3 failing test
    c2_cat3_execution = @product.product_tests.measure_tests.first.c2_task.test_executions.build(:state => :passed)
    c3_cat3_execution = @product.product_tests.measure_tests.first.c3_task.test_executions.build(:state => :failed)
    c2_cat3_execution.sibling_execution_id = c3_cat3_execution.id
    c2_cat3_execution.save
    c3_cat3_execution.save
  end

  def setup_filtering_tests
    @product.product_tests.create!({ name: 'Filter Test 1', cms_id: 'SomeCMSID', measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'],
                                     options: { filters: { filt1: ['val1'], filt2: ['val2'] } }
                                   }, FilteringTest)
    @product.product_tests.filtering_tests.each do |test|
      test.tasks.build({}, Cat1FilterTask)
      test.tasks.build({}, Cat3FilterTask)
    end

    # one cat1 passing execution, one cat3 failing execution
    @product.product_tests.filtering_tests.first.cat1_task.test_executions.create(:state => :passed)
    @product.product_tests.filtering_tests.first.cat3_task.test_executions.create(:state => :failed)
  end

  # # # # # # # # #
  #   T E S T S   #
  # # # # # # # # #

  def test_get_product_status_values
    certs = get_product_status_values(@product)
    assert_c1(certs.C1)
    assert_c2(certs.C2)
    assert_c3(certs.C3)
    assert_c4(certs.C4)
  end

  def assert_c1(cert)
    assert_equal 1, cert.checklist.failing
    assert_equal 1, cert.checklist.total

    assert_equal 1, cert.cat1.failing
    assert_equal 1, cert.cat1.not_started
    assert_equal 2, cert.cat1.total

    assert_equal 0, cert.sums.passing
    assert_equal 2, cert.sums.failing
    assert_equal 1, cert.sums.not_started
    assert_equal 3, cert.sums.total
  end

  def assert_c2(cert)
    assert_equal 1, cert.cat3.passing
    assert_equal 1, cert.cat3.not_started
    assert_equal 2, cert.cat3.total

    assert_equal 1, cert.sums.passing
    assert_equal 0, cert.sums.failing
    assert_equal 1, cert.sums.not_started
    assert_equal 2, cert.sums.total
  end

  def assert_c3(cert)
    assert_equal 1, cert.cat1.passing
    assert_equal 1, cert.cat1.not_started
    assert_equal 2, cert.cat1.total

    assert_equal 1, cert.cat3.failing
    assert_equal 1, cert.cat3.not_started
    assert_equal 2, cert.cat3.total

    assert_equal 1, cert.sums.passing
    assert_equal 1, cert.sums.failing
    assert_equal 2, cert.sums.not_started
    assert_equal 4, cert.sums.total
  end

  def assert_c4(cert)
    assert_equal 1, cert.cat1.passing
    assert_equal 1, cert.cat1.total

    assert_equal 1, cert.cat3.failing
    assert_equal 1, cert.cat3.total

    assert_equal 1, cert.sums.passing
    assert_equal 1, cert.sums.failing
    assert_equal 0, cert.sums.not_started
    assert_equal 2, cert.sums.total
  end
end
