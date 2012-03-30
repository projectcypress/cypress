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
    @test = ProductTest.find("4f58f8de1d41c851eb000478")
  end

  test "Should evaluate measures" do
    result = Cypress::MeasureEvaluator.eval(@test, @measure)
    
    assert result['numerator']    == 44, "Measure Evaluator reported wrong result for a measure"
    assert result['denominator']  == 48, "Measure Evaluator reported wrong result for a measure"
    assert result['exclusions']   == 0 , "Measure Evaluator reported wrong result for a measure"
    assert result['antinumerator']== 4 , "Measure Evaluator reported wrong result for a measure"
  end

  test "Should evaluate measures for static records" do
    result = Cypress::MeasureEvaluator.eval_for_static_records(@measure)

    assert result['numerator']    == 44, "Measure Evaluator reported wrong result for a measure"
    assert result['denominator']  == 50, "Measure Evaluator reported wrong result for a measure"
    assert result['exclusions']   == 0 , "Measure Evaluator reported wrong result for a measure"
    assert result['antinumerator']== 6 , "Measure Evaluator reported wrong result for a measure"
  end
end
