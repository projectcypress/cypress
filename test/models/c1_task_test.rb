require 'test_helper'
class C1TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    load_library_functions
    @product_test = ProductTest.find('51703a883054cf84390000d3')
  end

  def test_create
    assert @product_test.tasks.create({}, C1Task)
  end

  def test_should_exclude_c3_validators_when_no_c3
    @product_test.tasks.clear
    task = @product_test.tasks.create({}, C1Task)
    assert !@product_test.contains_c3_task?

    task.validators.each do |v|
      assert !v.is_a?(MeasurePeriodValidator)
    end
  end

  def test_should_be_able_to_test_a_good_archive_of_qrda_files
    task = @product_test.tasks.create({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip)
      te.reload
      assert te.execution_errors.empty?, 'should be no errors for good cat I archive'
    end
  end

  def test_should_be_able_to_tell_when_wrong_number_of_documents_are_supplied_in_archive
    task = @product_test.tasks.create({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_many_files.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip)
      te.reload
      assert_equal 1, te.execution_errors.length, 'should be 1 error from cat I archive'
    end
  end

  def test_should_be_able_to_tell_when_wrong_names_are_provided_in_documents
    task = @product_test.tasks.create({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_wrong_names.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip)
      te.reload
      assert_equal 2, te.execution_errors.length, 'should be 2 errors from cat I archive'
    end
  end

  def test_should_have_c3_execution_as_sibling_test_execution_when_c3_task_exists
    c1_task = @product_test.tasks.create({}, C1Task)
    c3_task = @product_test.tasks.create({}, C3Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip'))
    perform_enqueued_jobs do
      te = c1_task.execute(zip)
      assert_equal c3_task.test_executions.first.id.to_s, te.sibling_execution_id
    end
  end

  def test_should_be_able_to_tell_when_potentialy_too_much_data_is_in_documents
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({}, C3Task)
    task.last_execution = 'Cat1'
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_much_data.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, nil)
      te.reload
      assert_equal 39, te.execution_errors.length, 'should be 39 errors from cat I archive'
    end
  end

  def test_should_be_able_to_tell_when_calculation_errors_exist
    task = @product_test.tasks.create({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_bad_calculation.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip)
      te.reload
      assert_equal 2, te.execution_errors.length, 'should be 2 calculation errors from cat I archive'
    end
  end
end

require_relative '../helpers/caching_test'
class C1TaskCachingTest < CachingTest
  def test_task_status_is_not_cached_on_start
    assert !Rails.cache.exist?("#{@c1_task.cache_key}/status"), 'cache key for task status should not exist'
  end

  def test_task_status_is_cached_after_checking_status
    @c1_task.status
    assert Rails.cache.exist?("#{@c1_task.cache_key}/status"), 'cache key for task status should exist'
  end
end
