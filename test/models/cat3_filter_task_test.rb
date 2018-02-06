require 'test_helper'

class Cat3FilterTaskTest < ActiveSupport::TestCase
  include ::Validators
  include ActiveJob::TestHelper

  def setup
    @product_test = FactoryGirl.create(:static_filter_test)
  end

  def test_create
    assert @product_test.tasks.create({}, Cat3FilterTask)
  end

  def test_task_good_results_should_pass
    task = @product_test.tasks.create({ expected_results: @product_test.expected_results }, Cat3FilterTask)
    xml = Tempfile.new(['good_results_debug_file', '.xml'])
    xml.write task.good_results
    perform_enqueued_jobs do
      te = task.execute(xml, User.first)
      te.reload
      assert_empty te.execution_errors, 'test execution with known good results should not have any errors'
      assert te.passing?, 'test execution with known good results should pass'
    end
  end
end
