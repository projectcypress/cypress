class MeasureEvaluationJob < ApplicationJob
  queue_as :default
  include Job::Status
  def perform(test_or_task, options)
    if test_or_task.is_a? ProductTest
      perform_for_product_test(test_or_task, options)
    elsif test_or_task.is_a? Task
      perform_for_task(test_or_task, options)

    end
  end

  def perform_for_task(task, options)
    results = eval_measures(task.product_test.measures, task.product_test, options)
    task.expected_results = results
    task.save
  end

  def perform_for_product_test(product_test, options)
    results = eval_measures(product_test.measures, product_test, options)
    product_test.expected_results = results
    product_test.save
  end

  def eval_measures(measures, product_test, _options, &_block)
    erc = Cypress::ExpectedResultsCalculator.new(product_test.patients, product_test.id.to_s)
    results = erc.aggregate_results_for_measures(measures)
    results
  end
end
