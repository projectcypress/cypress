require 'test_helper'
require 'fileutils'

class PQRITest < ActiveSupport::TestCase

 
  test "Should import a PQRI file" do
    xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_passing.xml'))
    doc = Nokogiri::XML(xml_file)
    results = Cypress::PqriUtility.extract_results(doc, nil)
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

  end


  
  test "should validate 2010 PQRI" do
    xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_2010_1.xml'))
    doc = Nokogiri::XML(xml_file)
    errors = Cypress::PqriUtility.validate(doc)
    assert errors.size == 0,  "Should be 0 errors but there were #{errors}"
    
  end
  
  
  test "should validate 2009 PQRI "  do
     xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_2009_1.xml'))
     doc = Nokogiri::XML(xml_file)
     errors = Cypress::PqriUtility.validate(doc)
     assert_equal 0, errors.size, "Should be 0 errors but there were #{errors}"
    
  end
  
  
  test "should return errors for invalid 2010 PQRI" do
     xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_2010_invalid.xml'))
     doc = Nokogiri::XML(xml_file)
     errors = Cypress::PqriUtility.validate(doc)
     assert_equal 2, errors.size, "Should have 3 errors but was #{errors.size}"
   
    
  end
  
  
  test "should return errors for invalid 2009 PQRI"  do
     xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_2009_invalid.xml'))
     doc = Nokogiri::XML(xml_file)
     errors = Cypress::PqriUtility.validate(doc)
     assert_equal 4, errors.size, "Should have 3 errors but was #{errors.size}"
     
    
  end
  
  
  test "should handle PQRI that does not have a schema mapped for it" do
     xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_invalid_version_number.xml'))
      doc = Nokogiri::XML(xml_file)
      errors = Cypress::PqriUtility.validate(doc)
      assert_equal 1, errors.size
      assert_equal "Schema Not avaialble for version 5.0 to validate against", errors[0]
    
  end
  
end
