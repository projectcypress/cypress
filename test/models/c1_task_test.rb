require 'test_helper'
class C1TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    @product_test = FactoryBot.create(:product_test_static_result)
  end

  def test_create
    assert @product_test.tasks.create({}, C1Task)
  end

  def test_should_exclude_c3_validators_when_no_c3
    @product_test.tasks.clear
    task = @product_test.tasks.create({}, C1Task)

    task.validators.each do |v|
      assert_not v.is_a?(MeasurePeriodValidator)
    end
  end

  def test_should_be_able_to_test_a_good_archive_of_qrda_files
    @product_test.product.c1_test = true
    task = @product_test.tasks.create({}, C1Task)
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_good.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      assert te.execution_errors.where(:msg_type => :error).empty?, 'should be no errors for good cat I archive'
    end
  end

  def test_should_fail_with_a_good_archive_of_unshifted_qrda_files_for_shifted_test
    @product_test.product.shift_patients = true
    task = @product_test.tasks.create({}, C1Task)
    @product_test.product.c1_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_good.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      assert_equal false, te.execution_errors.where(:msg_type => :error).empty?, 'should be errors for unshifted cat I archive'
    end
  end

  def test_should_be_able_to_test_a_good_archive_of_shifted_qrda_files_for_shifted_test
    @product_test.product.shift_patients = true
    task = @product_test.tasks.create({}, C1Task)
    @product_test.product.c1_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_good_shift.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      assert te.execution_errors.where(:msg_type => :error).empty?, 'should be no errors for shifted good cat I archive'
    end
  end

  def test_should_be_able_to_test_a_good_archive_of_augmented_qrda_files
    task = @product_test.tasks.create({}, C1Task)
    @product_test.product.c1_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_good_aug.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      assert te.execution_errors.where(:msg_type => :error).empty?, 'should be no errors for good augmented cat I archive'
    end
  end

  def test_should_be_able_to_tell_when_wrong_number_of_documents_are_supplied_in_archive
    task = @product_test.tasks.create({}, C1Task)
    @product_test.product.c1_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_too_many_files.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      assert_equal 1, te.execution_errors.where(:msg_type => :error).count, 'should be 1 error from cat I archive'
      assert_equal 1, te.execution_errors.where(:message => '1 files expected but was 2', :msg_type => :error).count
    end
  end

  def test_should_be_able_to_tell_when_wrong_names_are_provided_in_documents
    task = @product_test.tasks.create({}, C1Task)
    @product_test.product.c1_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_wrong_names.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      assert_equal 2, te.execution_errors.where(:msg_type => :error).count, 'should be 2 errors from cat I archive'
      assert_equal 'Patient name \'DENTAL_PEDS A2\' declared in file not found in test records', te.execution_errors[0].message
      assert_equal 'Records for patients DENTAL_PEDS A not found in archive as expected', te.execution_errors[1].message
    end
  end

  def test_should_have_c3_execution_as_sibling_test_execution_when_c3_task_exists
    c1_task = @product_test.tasks.create!({}, C1Task)
    c3_task = @product_test.tasks.create!({}, C3Cat1Task)
    @product_test.product.c1_test = true
    @product_test.product.c3_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_good.zip'))
    perform_enqueued_jobs do
      te = c1_task.execute(zip, @user)
      assert_equal c3_task.test_executions.first.id.to_s, te.sibling_execution_id
    end
  end

  def test_should_return_warning_when_incorrect_templates_in_c1_without_c3
    task = @product_test.tasks.create({}, C1Task)
    @product_test.product.c1_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_wrong_templates.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      assert_equal 1, te.execution_errors.by_file('sample_patient_wrong_template.xml').where(:message => '["2.16.840.1.113883.10.20.24.3.133:2015-08-01"] are not valid Patient Data Section QDM entries for this QRDA Version', :msg_type => :warning).count
    end
  end

  def test_should_be_able_to_tell_when_calculation_errors_exist
    task = @product_test.tasks.create({}, C1Task)
    @product_test.product.c1_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_bad_calculation.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      # 1 NUMER and 1 DENOM population
      assert_equal 2, te.execution_errors.where(:msg_type => :error).count, 'should be 3 calculation errors from cat I archive'
    end
  end

  def test_should_be_able_to_tell_when_calculation_errors_exist_in_augmented_files
    task = @product_test.tasks.create({}, C1Task)
    @product_test.product.c1_test = true
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_bad_calculation_aug.zip'))
    perform_enqueued_jobs do
      te = task.execute(zip, @user)
      te.reload
      # 1 NUMER and 1 DENOM population
      assert_equal 2, te.execution_errors.where(:msg_type => :error).count, 'should be 8 calculation errors from cat I archive'
    end
  end

  def test_task_good_results_should_pass
    task = @product_test.tasks.create({}, C1Task)
    testfile = Tempfile.new(['good_results_debug_file', '.zip'])
    testfile.write task.good_results
    perform_enqueued_jobs do
      te = task.execute(testfile, @user)
      te.reload
      # 2 errors for calculation (should be in denom)
      assert_equal 0, te.execution_errors.where(:msg_type => :error).count, 'test execution with known good results should have no errors'
    end
  end

  # def test_should_be_able_to_tell_when_potentialy_too_much_data_is_in_documents
  #   # ptest = ProductTest.find('51703a883054cf84390000d3')
  #   task = @product_test.tasks.create({}, C3Cat1Task)
  #   zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_too_much_data.zip'))
  #   perform_enqueued_jobs do
  #     te = task.execute(zip, User.first, nil)
  #     te.reload
  #     assert_equal 1, te.execution_errors.by_file('sample_patient_too_much_data.xml').where(:message => 'File appears to contain data criteria outside that '\
  #       'required by the measures. Valuesets in file not in measures tested 1.17.18.19\'', :msg_type => :warning).count
  #   end
  # end
end

require_relative '../helpers/caching_test'
class C1TaskCachingTest < CachingTest
  # def test_task_status_is_not_cached_on_start
  #   assert !Rails.cache.exist?("#{@c1_task.cache_key}/status"), 'cache key for task status should not exist'
  # end

  # def test_task_status_is_cached_after_checking_status
  #   @c1_task.status
  #   assert Rails.cache.exist?("#{@c1_task.cache_key}/status"), 'cache key for task status should exist'
  # end
end
