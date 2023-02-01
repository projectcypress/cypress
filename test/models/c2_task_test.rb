# frozen_string_literal: true

require 'test_helper'

class C2TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    @product_test = FactoryBot.create(:product_test_static_result)
  end

  def test_create
    assert @product_test.tasks.create({}, C2Task)
  end

  def test_should_exclude_c3_validators_when_no_c3
    @product_test.tasks.clear
    task = @product_test.tasks.create({}, C2Task)

    task.validators.each do |v|
      assert_not v.is_a?(MeasurePeriodValidator)
    end
  end

  def test_execute
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    xml = create_rack_test_file('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_good.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, @user)
      te.reload
      assert te.execution_errors.empty?, 'should be no errors for good cat I archive'
    end
  end

  def test_should_not_error_when_measure_period_is_wrong_without_c3
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    xml = create_rack_test_file('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_bad_mp.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, @user)
      te.reload
      assert_empty te.execution_errors, 'should have no errors for the invalid reporting period'
    end
  end

  def test_should_cause_error_when_supplemental_data_is_missing
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.product.c2_test = true
    xml = create_rack_test_file('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_missing_supplemental.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, @user)
      te.reload
      assert_equal 1, te.execution_errors.to_a.count { |e| e.message == 'supplemental data error' }, 'should error on missing supplemental data'
      te.execution_errors.each do |ee|
        assert_equal :result_validation, ee.validator_type
      end
    end
  end

  def test_should_cause_error_when_the_schema_structure_is_bad
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    @product_test.product.c2_test = true
    xml = create_rack_test_file('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_bad_schematron.xml', 'text/xml')
    perform_enqueued_jobs do
      te = task.execute(xml, @user)
      te.reload
      assert_equal 1, te.execution_errors.to_a.count { |ee| ee.validator_type == :xml_validation }, 'should error on bad schematron'
    end
  end

  def test_task_good_results_should_pass
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, C2Task)
    xml = Tempfile.new(['good_results_debug_file', '.xml'])
    xml.write task.good_results
    perform_enqueued_jobs do
      te = task.execute(xml, @user)
      te.reload
      assert_empty te.execution_errors, 'test execution with known good results should not have any errors'
    end
  end

  def test_c2_task_last_update_with_sibling
    c2_task = @product_test.tasks.create({}, C2Task)
    # sleep to make sure the tasks are saved at different times
    sleep(1)
    c3_cat3_task = @product_test.tasks.create({}, C3Cat3Task)
    c2_task.reload
    c3_cat3_task.reload
    # c3_cat3_task was saved last and should be returned
    assert_equal c3_cat3_task.updated_at, c2_task.last_updated_with_sibling
    c2_task.options = { what: 'what' }
    c2_task.save
    c2_task.reload
    # c2_task was saved last and should be returned
    assert_equal c2_task.updated_at, c2_task.last_updated_with_sibling
  end

  def test_c2_task_status_with_sibling
    c2_task = @product_test.tasks.find_by(_type: 'C2Task')
    c3_cat3_task = @product_test.tasks.create({}, C3Cat3Task)
    c2_execution = c2_task.test_executions.create!(user: @user)
    c3_execution = c3_cat3_task.test_executions.create!(user: @user)
    c2_execution.state = :passed
    c2_execution.save
    # status is incomplete when there isn't a c3 execution
    assert_equal 'pending', c2_task.status_with_sibling

    c2_execution.state = :failed
    c2_execution.save
    c3_execution.state = :passed
    c3_execution.save
    # c2 failed overrides passed c3
    assert_equal 'failing', c2_task.status_with_sibling

    c3_execution.state = :errored
    c3_execution.save
    # c3 errored overrides failed c2
    assert_equal 'errored', c2_task.status_with_sibling
  end

  def pop_sum_err_regex
    /\AReported \w+ [a-zA-Z\d-]{36} value \d+ does not match sum \d+ of supplemental key \w+ values\z/
  end
end
