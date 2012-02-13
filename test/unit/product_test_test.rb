require 'test_helper'

class ProductTestTest < ActiveSupport::TestCase
  setup do
    collection_fixtures('product_tests', '_id')
  end
  
  test "that ProductTests can import a PQRI file" do
    test = ProductTest.new
    doc = Nokogiri::XML(File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri.xml')))
    test.reported_results = test.extract_results_from_pqri(doc)
    
    assert test.reported_results != nil
    assert test.reported_results.size==2
    assert test.reported_results['0421a'] != nil
    assert test.reported_results['0421a']['denominator'] == 80
    assert test.reported_results['0421a']['numerator'] == 39
    assert test.reported_results['0421a']['exclusions'] == 0
    assert test.reported_results['0421b'] != nil
    assert test.reported_results['0421b']['denominator'] == 300
    assert test.reported_results['0421b']['numerator'] == 71
    assert test.reported_results['0421b']['exclusions'] == 0
  end
end