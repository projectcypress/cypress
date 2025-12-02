# frozen_string_literal: true

namespace :evaluator do
  task setup: :environment

  desc %(
    Clean up generated vendor/product/tests/executions in Cypress
  )
  task cleanup: :setup do
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

  task :api_evaluate_random, %i[cypress_host hqmf_path use_js_ecqm] => :setup do |_, args|
    options = args.to_hash
    options[:randomization] = true
    api_ev = Cypress::ApiMeasureEvaluator.new(ENV.fetch('USERNAME', nil), ENV.fetch('PASSWORD', nil), options)
    api_ev.cleanup
    api_ev.run_measure_eval(true, false)
  end

  task :api_evaluate_c1_c2, %i[cypress_host hqmf_path use_js_ecqm] => :setup do |_, args|
    api_ev = Cypress::ApiMeasureEvaluator.new(ENV.fetch('USERNAME', nil), ENV.fetch('PASSWORD', nil), args.to_hash)
    api_ev.cleanup
    api_ev.run_measure_eval(true, false)
  end

  task :api_evaluate_c4, %i[cypress_host hqmf_path use_js_ecqm] => :setup do |_, args|
    options = args.to_hash
    options[:randomization] = true
    api_ev = Cypress::ApiMeasureEvaluator.new(ENV.fetch('USERNAME', nil), ENV.fetch('PASSWORD', nil), options)
    api_ev.cleanup
    api_ev.run_measure_eval(false, true)
  end

  task :api_evaluate_all, %i[cypress_host hqmf_path use_js_ecqm] => :setup do |_, args|
    options = args.to_hash
    options[:randomization] = true
    api_ev = Cypress::ApiMeasureEvaluator.new(ENV.fetch('USERNAME', nil), ENV.fetch('PASSWORD', nil), options)
    api_ev.cleanup
    api_ev.run_measure_eval(true, true)
  end
end
