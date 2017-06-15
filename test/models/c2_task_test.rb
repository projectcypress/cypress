require 'test_helper'

class C2TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @product_test = ProductTest.find('51703a6a3054cf8439000044')
  end

  def test_create
    assert @product_test.tasks.create({}, C2Task)
  end

  def test_should_exclude_c3_validators_when_no_c3
    @product_test.tasks.clear
    task = @product_test.tasks.create({}, C2Task)

    task.validators.each do |v|
      assert !v.is_a?(MeasurePeriodValidator)
    end
  end

  def test_execute
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_good.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      assert te.execution_errors.empty?, 'should be no errors for good cat I archive'
    end
  end

  def test_should_not_error_when_measure_period_is_wrong_without_c3
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_mp.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      assert_empty te.execution_errors, 'should have no errors for the invalid reporting period'
    end
  end

  def test_should_cause_error_when_stratifications_are_missing
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.product.c2_test = true
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_missing_stratification.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      # Missing strat for the 1 numerator that has data
      assert_equal 19, te.execution_errors.length # 10 errors related to pop sums
      assert_equal 10, te.execution_errors.to_a.count { |e| !pop_sum_err_regex.match(e.message).nil? }
      assert_equal 1, (te.execution_errors.to_a.count do |e|
        !/\ACould not find value for stratification [a-zA-Z\d\-]{36}  for Population \w+\z/.match(e.message).nil?
      end), 'should error on missing stratifications'
    end
  end

  def test_should_cause_error_when_supplemental_data_is_missing
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.product.c2_test = true
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_missing_supplemental.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      # checked 3 times for each numerator -- we should do something about that
      assert_equal 24, te.execution_errors.length # 13 errors related to pop sums
      assert_equal 13, te.execution_errors.to_a.count { |e| !pop_sum_err_regex.match(e.message).nil? }
      assert_equal 3, te.execution_errors.to_a.count { |e| e.message == 'supplemental data error' }, 'should error on missing supplemental data'
      te.execution_errors.each do |ee|
        assert_equal :result_validation, ee.validator_type
      end
    end
  end

  def test_should_cause_error_when_the_schema_structure_is_bad
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.product.c2_test = true
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_schematron.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      # 3 errors 1 for schema validation and 2 schematron issues for realmcode
      assert_equal 21, te.execution_errors.length # 10 errors related to pop sums
      assert_equal 10, te.execution_errors.to_a.count { |e| !pop_sum_err_regex.match(e.message).nil? }
      assert_equal 3, te.execution_errors.to_a.count { |ee| ee.validator_type == :xml_validation }, 'should error on bad schematron'
    end
  end

  def test_should_cause_error_when_measure_is_not_included_in_report
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.product.c2_test = true
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_missing_measure.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload

      # 9 is for all of the sub measures to be searched for
      # 46 for missing supplemental data
      # 2 for incorrect measure ids
      assert_equal 105, te.execution_errors.length, 'should error on missing measure entry'
    end
  end

  def test_should_cause_error_when_extra_supplemental_data_is_provided
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.product.c2_test = true
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_extra_supplemental.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      # 1 Error for additional Race
      assert_equal 20, te.execution_errors.length
      assert_equal 11, te.execution_errors.to_a.count { |e| !pop_sum_err_regex.match(e.message).nil? }
      assert_equal 1, te.execution_errors.to_a.count { |e| e.message == 'supplemental data error' }, 'should error on additional supplemental data'
    end
  end

  def test_should_not_cause_error_when_extra_supplemental_data_provided_has_zero_value
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_extra_supplemental_is_zero.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      assert te.execution_errors.empty?, 'should not error on additional supplemental data value equal to 0'
    end
  end

  def test_should_have_c3_execution_as_sibling_test_execution_when_c3_task_exists
    c2_task = @product_test.tasks.create({}, C2Task)
    c3_task = @product_test.tasks.create({}, C3Cat3Task)
    @product_test.product.c3_test = true
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_good.xml', 'text/xml')
    perform_enqueued_jobs do
      te = c2_task.execute(xml, User.first)
      assert_equal c3_task.test_executions.first.id.to_s, te.sibling_execution_id
    end
  end

  def test_task_good_results_should_pass
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C2Task)
    xml = Tempfile.new(['good_results_debug_file', '.xml'])
    xml.write task.good_results
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      assert_empty te.execution_errors, 'test execution with known good results should not have any errors'
    end
  end

  def pop_sum_err_regex
    /\AReported \w+ [a-zA-Z\d\-]{36} value \d+ does not match sum \d+ of supplemental key \w+ values\z/
  end
end
