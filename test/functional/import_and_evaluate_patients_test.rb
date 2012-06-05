require 'test_helper'
require 'active_support/testing/pending'
class ImportAndEvaluateTest < ActionController::TestCase
  
  setup do

    wipe_db_and_load_patients()
    load_measures()
  end
  
  test "Import records and eval against all measures" do
    pending "Trying to figure out if the test or the baseline data is wrong" do
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
end
