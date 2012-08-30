require 'test_helper'
require 'fileutils'

class QRDATest < ActiveSupport::TestCase

 
  test "Should import a QRDA file" do
    xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'))
    doc = Nokogiri::XML(xml_file)
    results = Cypress::QrdaUtility.extract_results(doc, nil)
    measure1 = results['0436']
    measure2 = results['0496']

    assert measure1['measure_population'] == '-'
    assert measure1['initial_population'] == 1000
    assert measure1['numerator'] == 400
    assert measure1['numerator_exclusions'] == '-'
    assert measure1['denominator'] == 500
    assert measure1['denominator_exclusions'] == 20
    assert measure1['denominator_exceptions'] == '-'

    assert measure2['measure_population'] == 500
    assert measure2['initial_population'] == 1000
    assert measure2['numerator'] == '-'
    assert measure2['numerator_exclusions'] == '-'
    assert measure2['denominator'] == '-'
    assert measure2['denominator_exclusions'] == '-'
    assert measure2['denominator_exceptions'] == '-'

  end


  
  # test "should validate QRDA " do
  #   xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_2010_1.xml'))
  #   doc = Nokogiri::XML(xml_file)
  #   errors = Cypress::PqriUtility.validate(doc)
  #   assert errors.size == 0,  "Should be 0 errors but there were #{errors}"
    
  # end
  
end
