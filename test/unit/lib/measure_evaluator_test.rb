require 'test_helper'

class MeasureEvaluatorTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('test_executions', '_id')
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id')
    collection_fixtures('measures')
	  collection_fixtures('query_cache','_id','test_id')
    collection_fixtures('patient_cache','_id')

    @measure = Measure.where({:id => '0001'}).first
    @result = {"measure_id" => @measure['id'],
               "effective_date" => 1293753600,
               "denominator" => 48,
               "numerator" => 44,
               "antinumerator" => 4,
               "exclusions" => 0 }
    @test = ProductTest.find("4f58f8de1d41c851eb000478")
  end

  test "Should evaluate measures" do
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)
    
    result = Cypress::MeasureEvaluator.eval(@test, @measure)
    
    assert result['numerator']    == 44, "Measure Evaluator reported wrong result for a measure"
    assert result['denominator']  == 48, "Measure Evaluator reported wrong result for a measure"
    assert result['exclusions']   == 0 , "Measure Evaluator reported wrong result for a measure"
    assert result['antinumerator']== 4 , "Measure Evaluator reported wrong result for a measure"
  end
  
  test "resque jobs are created for uncalculated measures" do
    QME::QualityReport.any_instance.stubs(:calculated?).returns(false)
    QME::QualityReport.any_instance.stubs(:calculate).returns("123456") # A fake resque job uuid
    QME::QualityReport.any_instance.stubs(:status).returns("working")
    
    assert @test.result_calculation_jobs.empty?
    result = Cypress::MeasureEvaluator.eval(@test, @measure)
    
    assert_equal @test.result_calculation_jobs.size, 1
    assert result['numerator']    == '?',  "Expecting numerator " + result['numerator']
    assert result['denominator']  == '?',  "Expecting denominator " + result['denominator']
    assert result['exclusions']   == '?' , "Expecting exclusions " + result['exclusions']
  end

  test "results are returned for calculated measures on static records" do
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)
    
    result = Cypress::MeasureEvaluator.eval_for_static_records(@measure)
    
    assert result['numerator']    == 44, "Measure Evaluator reported wrong result for a measure"
    assert result['denominator']  == 48, "Measure Evaluator reported wrong result for a measure"
    assert result['exclusions']   == 0 , "Measure Evaluator reported wrong result for a measure"
    assert result['antinumerator']== 4 , "Measure Evaluator reported wrong result for a measure"
  end
  
  test "temporary values are returned for uncalculated measure" do
    QME::QualityReport.any_instance.stubs(:calculated?).returns(false)
    QME::QualityReport.any_instance.stubs(:calculate)
    
    result = Cypress::MeasureEvaluator.eval_for_static_records(@measure)
    
    assert result['numerator']    == '?',  "Expecting numerator " + result['numerator']
    assert result['denominator']  == '?',  "Expecting denominator " + result['denominator']
    assert result['exclusions']   == '?' , "Expecting exclusions " + result['exclusions']
  end
end