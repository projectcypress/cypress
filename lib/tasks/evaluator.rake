namespace :evaluator do
  task :setup => :environment

  desc %(
    Clean up generated vendor/product/tests/executions in Cypress
  )
  task :cleanup => :setup do
    mev = Cypress::MeasureEvaluator.new
    mev.cleanup
  end

  task :evaluate_all_cat3, [:cypress_user] => :setup do |_, args|
    mev = Cypress::MeasureEvaluator.new(args.to_hash)
    mev.evaluate_all_cat3
  end
end
