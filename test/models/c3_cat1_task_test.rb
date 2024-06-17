# frozen_string_literal: true

require 'test_helper'
class C3Cat1TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    @test = FactoryBot.create(:cv_product_test_static_result)
    @test.product.c3_test = true
    @task = @test.tasks.create({}, C3Cat1Task)
  end

  def test_task_should_include_c3_cat1_validators
    assert(@task.validators.any? { |v| v.is_a?(MeasurePeriodValidator) })
  end

  def test_task_should_not_error_when_extra_record_included
    c1_task = @test.tasks.create!({}, C1Task)
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_too_many_files.zip'))
    perform_enqueued_jobs do
      te = @task.execute(zip, @user, c1_task)
      te.reload
      assert_empty te.execution_errors.where(file_name: '0_Dental_Peds_A copy.xml'), 'should be no errors from extra file'
      # expected errors: none
    end
  end

  def test_should_be_able_to_test_missing_ccde_ids_with_lowercase_id
    measure = @task.measures.first
    measure.hqmf_id = '2C928082-74C2-3313-0174-E01E3F200882'
    measure.save
    @test.measure_ids = ['2C928082-74C2-3313-0174-E01E3F200882']
    @test.product.measure_ids = ['2C928082-74C2-3313-0174-E01E3F200882']
    @test.save
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_ccde_lowercase.zip'))
    c1_task = @test.tasks.create!({}, C1Task)
    perform_enqueued_jobs do
      te = @task.execute(zip, @user, c1_task)
      te.reload
      assert_equal 0, te.execution_errors.where(message: 'CMS_0086 - Files containing hybrid measure/CCDE submissions and eCQM cannot be submitted within the same batch').size
    end
  end
end
