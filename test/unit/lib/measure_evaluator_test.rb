require 'test_helper'

class MeasureEvaluatorTest < ActiveSupport::TestCase

  setup do

    collection_fixtures('test_executions', '_id')
    collection_fixtures('products', '_id','vendor_id')
    collection_fixtures('product_tests', '_id','product_id')
    collection_fixtures('measures', "_id",'bundle_id')
	  collection_fixtures('query_cache','_id','test_id')
    collection_fixtures('patient_cache','_id','bundle_id', "value.test_id")
    collection_fixtures('bundles', '_id')

    @measure = Measure.where({:hqmf_id => '0001'}).first

    @result = QME::QualityReportResult.new(DENOM: 48, NUMER: 44, antinumerator: 4, DENEX: 0)
    @test = ProductTest.find("4f58f8de1d41c851eb000478")
  end

  test "Should evaluate measures" do
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)

    result = Cypress::MeasureEvaluator.eval(@test, @measure)

    assert result['NUMER']    == 44, "Measure Evaluator reported wrong NUMER result for a measure"
    assert result['DENOM']  == 48, "Measure Evaluator reported wrong DENOM result for a measure"
    assert result['DENEX']   == 0 , "Measure Evaluator reported wrong DENEX result for a measure"
    assert result['antinumerator']== 4 , "Measure Evaluator reported wrong antinumerator result for a measure"
  end



  test "results are returned for calculated measures on static records" do
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)

    result = Cypress::MeasureEvaluator.eval_for_static_records(@measure)

    assert result['NUMER']    == 44, "Measure Evaluator reported wrong result for a measure"
    assert result['DENOM']  == 48, "Measure Evaluator reported wrong result for a measure"
    assert result['DENEX']   == 0 , "Measure Evaluator reported wrong result for a measure"
    assert result['antinumerator']== 4 , "Measure Evaluator reported wrong result for a measure"
  end

  test "temporary values are returned for uncalculated measure" do
    QME::QualityReport.any_instance.stubs(:calculated?).returns(false)
    QME::QualityReport.any_instance.stubs(:calculate)

    result = Cypress::MeasureEvaluator.eval_for_static_records(@measure)

    assert result['NUMER']    == '?',  "Expecting numerator " + result['NUMER']
    assert result['DENOM']  == '?',  "Expecting denominator " + result['DENOM']
    assert result['DENEX']   == '?' , "Expecting exclusions " + result['DENEX']
  end
end
