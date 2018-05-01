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

  def eval_measures(measures, product_test, options, &_block)
    results = {}
    erc = Cypress::ExpectedResultsCalculator.new(product_test.patients)
    measures.each_with_index do |measure|
      individual_results = IndividualResult.where('measure' => measure.id, 'extended_data.correlation_id' => product_test.id.to_s)
      results[measure.key] = erc.aggregate_results(individual_results, measure.population_ids)
      results[measure.key]['measure_id'] = measure.hqmf_id
      create_query_cache_object(results[measure.key], product_test, measure)
    end
    results
  end

  def create_query_cache_object(result, product_test, measure)
    result['test_id'] = product_test.id
    result['effective_date'] = product_test.effective_date
    result['sub_id'] = measure.sub_id if measure.sub_id
    Mongoid.default_client["query_cache"].insert_one(result)
  end

end
