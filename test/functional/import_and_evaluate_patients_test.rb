require 'test_helper'

class ImportAndEvaluateTest < ActionController::TestCase
  
  setup do
    if !ENV['MEASURE_DIR']
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      puts "Cannot run Import and Evaluate test, missing environment variable MEASURE_DIR"
      puts "Set MEASURE_DIR to the directory where the Measures project resides"
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      return
    end
    ENV['MEASURE_PROPS'] = ENV['MEASURE_PROPS'] || ENV['MEASURE_DIR'] + '/measure_props'
    wipe_db_and_load_patients()
    loader = QME::Database::Loader.new('cypress_test')
    loader.save_bundle(ENV['MEASURE_DIR'],'measures')
  end
  
  test "Import records and eval against all measures" do
    if !ENV['MEASURE_PROPS']
      assert true
      return
    end
    assert Record.count  == 225 , "Wrong number of records in DB"
    assert Measure.count == 78  , "Wrong number of measures in DB"
    expected_results_file = File.new(Rails.root.join("public","mpl_results_baseline.txt"), "r")
    expected_results = expected_results_file.readlines
    current_results  = []

    Measure.installed.each do |measure|
      result = Cypress::MeasureEvaluator.eval_for_static_records(measure,false)
      current_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["numerator"]:'   + result['numerator'].to_s + "\n")
      current_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["denominator"]:' + result['denominator'].to_s + "\n")
      current_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["exclusions"]:'  + result['exclusions'].to_s + "\n")
    end
    assert current_results.count == expected_results.count
    
    correct = true
    expected_results.zip(current_results) do |expected,current|
      if expected != current
        puts "Expected Result:   " + expected
        puts "Calculated Result: "+ current
        correct = false
      end
    end
    assert correct, "Incorrect results calculated"
  end
end
