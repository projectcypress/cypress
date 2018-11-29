class MeasureEvaluationJob < ApplicationJob
  queue_as :default
  include Job::Status

  # The MeasureEvaluationJob aggregates Individual Results to calculated the expected results for a
  # Measure Test or Task
  #
  # @param [Object] test_or_task The ProductTest or Task being evalutated
  # @param [Hash] options :individual_results are the raw results from JsEcqmCalc
  # @return none
  def perform(test_or_task, options)
    # Measure Evaluation Job can be run for a test (Measure Test), or a task (Filter Tasks)
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

  def eval_measures(measures, product_test, options, &_block)
    erc = Cypress::ExpectedResultsCalculator.new(product_test.patients, product_test.id.to_s, product_test.effective_date)
    # if individual_results results are nested within 'Individual'.  If there are no individual results, set to nil
    individual_results = options[:individual_results] || nil
    results = erc.aggregate_results_for_measures(measures, individual_results)
    results
  end
end
