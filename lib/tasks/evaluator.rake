namespace :evaluator do
  task :setup => :environment

  desc %(
    Clean up generated vendor/product/tests/executions in Cypress
  )
  task :cleanup => :setup do
    mev = Cypress::MeasureEvaluator.new
    mev.cleanup
  end

  desc %(
    Generate and execute C2/C3 product tests for all measures
  )
  task :evaluate_all_cat3, [:cypress_user] => :setup do |_, args|
    mev = Cypress::MeasureEvaluator.new(args.to_hash)
    mev.evaluate_all_cat3
  end

  desc %(
    Generate and execute C1/C3 product tests for all measures
  )
  task :evaluate_all_cat1, [:cypress_user] => :setup do |_, args|
    mev = Cypress::MeasureEvaluator.new(args.to_hash)
    mev.evaluate_all_cat1
  end

  desc %(
    Generate and execute C1/C2/C3 product tests for all measures, cat3 and cat1
  )
  task :evaluate_all, [:cypress_user] => :setup do |_, args|
    mev = Cypress::MeasureEvaluator.new(args.to_hash)
    mev.evaluate_all_cat3
    mev.evaluate_all_cat1
  end

  task :api_evaluate, [:cypress_host] => :setup do |_, args|
    api_ev = Cypress::ApiMeasureEvaluator.new(args.to_hash)
    api_ev.cleanup
    api_ev.run_measure_eval
  end
end
