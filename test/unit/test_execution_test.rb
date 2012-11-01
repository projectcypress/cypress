require 'test_helper'

class TestExecutionTest < ActiveSupport::TestCase

  setup do
 
    collection_fixtures('test_executions', '_id')
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id')
    collection_fixtures('measures')
    collection_fixtures('query_cache','_id','test_id')
    collection_fixtures('patient_cache','_id')
    
    @execution_failed = TestExecution.find("4f58fade1d41c851eb00047f")
    @execution_passed = TestExecution.find("4f5900981d41c851eb000482")
    @execution_half_passed = TestExecution.find("4f5900161d41c851eb000481")
  end
  
  
  test "New TestExecution should transition states correctly"  do
    
    te = TestExecution.new
    te.save
    assert_equal :pending, te.state
    
    te.failed
    assert_equal :failed, te.state
    
    te.force_pass
    assert_equal :passed, te.state
    
    te.force_fail
    assert_equal :failed, te.state
    
    te.reset
    assert_equal :pending, te.state
    
    te.pass
    assert_equal :passed, te.state
    
  end
  
  # test "Should know if it passed or failed" do
  #   assert @execution_failed.state == :failed,  "Failing execution reporting it passed"
  #   assert @execution_passed.state == :passed, "Passing execution reporting it failed"
  # end
  # 
  # test "Should know how many measures are passing" do
  #   assert @execution_failed.count_passing == 0, "Execution reporting wrong number of passing measures"
  #   assert @execution_passed.count_passing == 2, "Execution reporting wrong number of passing measures"
  #   assert @execution_half_passed.count_passing   == 1, "Execution reporting wrong number of passing measures"
  # end
  # 
  # test "Should know which measures passed and which measures failed" do
  #   passing = @execution_half_passed.passing_measures
  #   failing = @execution_half_passed.failing_measures
  #   
  #   assert passing.size == 1 , "Execution reporting wrong # of passing measures"
  #   assert passing[0].measure_id == "0001" , "Execution reporting wrong passing measure"
  #   
  #   assert failing.size == 1 , "Execution reporting wrong # of failing measures"
  #   assert failing[0].measure_id == "0002" , "Execution reporting wrong failing measure"
  # end
  # 
  # test "Should report correct result for particular measure" do
  #   measure1 = @execution_half_passed.reported_result('0001')
  #   measure_fail = @execution_half_passed.reported_result('SHOULD_FAIL')
  #   
  #   assert measure1['numerator']    == 44, "Execution reported wrong result for a measure"
  #   assert measure1['denominator']  == 48, "Execution reported wrong result for a measure"
  #   assert measure1['exclusions']   == 0 , "Execution reported wrong result for a measure"
  #   assert measure1['antinumerator']== 4 , "Execution reported wrong result for a measure"
  #   
  #   assert measure_fail['numerator']    == '--', "Execution reported a result for a non-existent measure"
  #   assert measure_fail['denominator']  == '--', "Execution reported a result for a non-existent measure"
  #   assert measure_fail['exclusions']   == '--', "Execution reported a result for a non-existent measure"
  #   assert measure_fail['antinumerator']== '--', "Execution reported a result for a non-existent measure"
  # end
  # 
  # 
  # 
  # test "Should properly normalize measure test results" do
  #   @execution_passed.baseline_results ={'0001' => {'numerator' => 10, 'denominator' => 5, 'exclusions' => 0, 'antinumerator' => 1}}
  #   @execution_passed.normalize_results_with_baseline
  #   measure1 = @execution_passed.reported_result('0001')
  #   
  #   assert measure1['numerator']   == 34 ,"numerator"
  #   assert measure1['denominator'] == 43,"denumerator"
  #   assert measure1['exclusions'] == 0,"exc"
  #   assert measure1['antinumerator'] == 3,"antinumerator"
  # end
  # 
  
  #Why wont this work? 
  # test "Should report correct success rate" do
  #   assert @execution_failed.success_rate == 0
  #   assert @execution_passed.success_rate == 1
  #   assert @execution_half_passed.success_rate == 0.5
  # end
end
