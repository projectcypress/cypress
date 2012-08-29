require 'test_helper'
require 'active_support/testing/pending'
class ImportAndEvaluateTest < ActionController::TestCase
  
  setup do

    @patient_count = wipe_db_and_load_patients()
    load_measures()
  end
  
  test "Import records and eval against all measures" do
    
    pending "Need to incorporate new measures from Bonnie and rework to make sure the results are correct" do
      if @patient_count == 225
        assert_equal 225, Record.count   , "Wrong number of records in DB"
        assert_equal 78, Measure.count  , "Wrong number of measures in DB"
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
      else
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        puts "MPL directory does not have all 225 records needed to run this test"
        puts "Please download the latest master patient list using the rake task mpl:update"
        puts "And re-run this test"
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      end
    end # ending the pedning block
  end
end
