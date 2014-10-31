namespace :measure_evaluation_validator do
  require 'pry'
  require 'pry-nav'

  task :setup => :environment

  desc %{Clean up generated vendor/product/tests/executions in Cypress
    
  }
  task :cleanup => :setup do
    mev = Cypress::MeasureEvaluationValidator.new
    mev.cleanup
  end

  desc %{Generates all measures as Cat III tests, and uploads Cat IIIs to them. If they're already generated, will upload another Cat III
      options
      cypress_user  - the username (full email) for the cypress user to be associated with the products/tests/vendors
  }
  task :evaluate_all_cat3, [:cypress_user] => :setup do |t, args|
    mev = Cypress::MeasureEvaluationValidator.new(args.to_hash)
    mev.evaluate_all_singly
  end

  desc %{Generates a random subset of n multi-measure tests, with m measures per test
    options
    cypress_user  - the username (full email) for the cypress user to be associated with the products/tests/vendors
    num_tests  - the number of tests to generate
    num_measures  - the number of measures per test
  }
  task :evaluate_multi_measures, [:cypress_user,:num_tests,:num_measures] => :setup do |t, args|
    mev = Cypress::MeasureEvaluationValidator.new(args.to_hash)
    mev.evaluate_multi_measures
  end

  desc %{Generates all measures as Cat I tests, and uploads Cat Is to them. If they're already generated, will generate another set.
      options
      cypress_user  - the username (full email) for the cypress user to be associated with the products/tests/vendors
  }
  task :evaluate_all_cat1, [:cypress_user] => :setup do |t, args|
    mev = Cypress::MeasureEvaluationValidator.new(args.to_hash)
    mev.evaluate_all_cat1
  end

  task :evaluate_all, [:cypress_user,:num_tests,:num_measures] => :setup do |t, args|
    mev = Cypress::MeasureEvaluationValidator.new(args.to_hash)
    mev.evaluate_all_singly
    mev.evaluate_multi_measures
    mev.evaluate_all_cat1
  end

end