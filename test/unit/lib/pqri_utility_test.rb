require 'test_helper'
require 'fileutils'

class PQRITest < ActiveSupport::TestCase

  setup do
    @xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_passing.xml'))
  end

  test "Should import a PQRI file" do
    doc = Nokogiri::XML(@xml_file)
    results = Cypress::PqriUtility.extract_results(doc)
    assert results.size == 2
    measure1 = results['0001']
    measure2 = results['0002']

    assert measure1['denominator'] == 48
    assert measure1['numerator']   == 44
    assert measure1['exclusions']  == 0
    assert measure1['antinumerator'] == 4

    assert measure2['denominator'] == 15
    assert measure2['numerator']   == 13
    assert measure2['exclusions']  == 0
    assert measure2['antinumerator'] == 2

    @xml_file.close
  end

  test "Should return PQRI validation errors " do
    doc = Nokogiri::XML(@xml_file)
    errors = Cypress::PqriUtility.validate(doc)
    assert errors.size == 6

    assert errors.index{|e| e=="Element 'submission', attribute 'option': [facet 'pattern'] The value 'PAYMENT' is not accepted by the pattern 'PQRI-REGISTRY|TEST'."} != nil
    assert errors.index{|e| e=="Element 'submission', attribute 'option': 'PAYMENT' is not a valid value of the atomic type 'pqriSubmissionOption'."} != nil
    assert errors.index{|e| e=="Element 'submission', attribute 'version': [facet 'pattern'] The value '3.0' is not accepted by the pattern '2.0'."} != nil
    assert errors.index{|e| e=="Element 'submission', attribute 'version': '3.0' is not a valid value of the atomic type 'pqriSubmissionVersion'."} != nil
    assert errors.index{|e| e=="Element 'collection-method': This element is not expected. Expected is ( eligible-instances )."} != nil

    @xml_file.close
  end
end
