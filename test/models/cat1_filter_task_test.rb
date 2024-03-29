# frozen_string_literal: true

require 'test_helper'

class Cat1FilterTaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @product_test = FactoryBot.create(:static_filter_test)
  end

  def test_create
    assert @product_test.tasks.create({}, Cat1FilterTask)
  end

  def test_task_good_results_should_pass
    user = User.create(email: 'testvendor@test.com', password: 'TestTest!', password_confirmation: 'TestTest!', terms_and_conditions: '1')
    task = @product_test.tasks.create({}, Cat1FilterTask)
    testfile = Tempfile.new(['good_results_debug_file', '.zip'])
    testfile.write task.good_results
    perform_enqueued_jobs do
      te = task.execute(testfile, user)
      te.reload
      assert_empty te.execution_errors, 'test execution with known good results should have no errors'
    end
  end
end
