require 'test_helper'
class C3Cat1TaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @user = User.create(email: 'vendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    @test = FactoryBot.create(:product_test_static_result)
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
end
