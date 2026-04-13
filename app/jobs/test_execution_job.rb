# frozen_string_literal: true

class TestExecutionJob < ApplicationJob
  include Job::Status
  queue_as :default

  after_enqueue do |job|
    task = job.arguments[1]
    broadcast_measure_test_row(task)
    job.tracker.add_options(
      test_execution_id: job.arguments[0].id,
      task_id: task.id
    )
  end

  def perform(test_execution, task, options = {})
    test_execution.update!(state: :running)
    task.update!(latest_test_execution_id: test_execution.id.to_s)

    test_execution.validate_artifact(
      task.validators,
      test_execution.artifact,
      options.merge('test_execution' => test_execution, 'task' => task)
    )

    test_execution.save!

    broadcast_measure_test_row(task.reload, options)
  end

  private

  def broadcast_measure_test_row(task, options = {})
    Turbo::StreamsChannel.broadcast_update_to(
      [task.product_test.product, :measure_tests],
      target: ApplicationController.helpers.measure_tests_table_row_wrapper_id(task),
      partial: 'products/measure_tests_table_row',
      locals: {
        task: task,
        html_id: options[:html_id],
        product_url: options[:product_url]
      }
    )
  end
end
