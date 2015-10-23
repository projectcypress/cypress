require 'test_helper'
class C1TaskTest < MiniTest::Test
  include ::Validators
  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @product_test = ProductTest.find('51703a883054cf84390000d3')
  end

  def after_teardown
    drop_database
  end

  def test_create
    assert @product_test.tasks.create({}, C1Task)
  end

  def test_should_be_able_to_test_a_good_archive_of_qrda_files
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip'))
    te = task.execute(zip)
    assert te.execution_errors.empty?, 'should be no errors for good cat I archive'
  end

  def test_should_be_able_to_tell_when_wrong_number_of_documents_are_supplied_in_archive
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_many_files.zip'))
    te = task.execute(zip)
    assert_equal 1, te.execution_errors.length, 'should be 1 error from cat I archive'
  end

  def test_should_be_able_to_tell_when_wrong_names_are_provided_in_documents
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_wrong_names.zip'))
    te = task.execute(zip)
    assert_equal 2, te.execution_errors.length, 'should be 2 errors from cat I archive'
  end

  def test_should_be_able_to_tell_when_potentialy_too_much_data_is_in_documents
    ptest = ProductTest.find('51703a883054cf84390000d3')
    task = ptest.tasks.create({}, C1Task)
    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_much_data.zip'))
    te = task.execute(zip)
    assert_equal 1, te.execution_errors.length, 'should be 1 error from cat I archive'
  end
end

class C1TaskCachingTest < CachingTest
  def test_task_status_is_not_cached_on_start
    assert !Rails.cache.exist?("#{@c1_task.cache_key}/status"), 'cache key for task status should not exist'
  end

  def test_task_status_is_cached_after_checking_status
    @c1_task.status
    assert Rails.cache.exist?("#{@c1_task.cache_key}/status"), 'cache key for task status should exist'
  end
end
