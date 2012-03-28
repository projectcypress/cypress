ENV["RAILS_ENV"] = "test"

require 'test_helper'
require 'builder'
require 'nokogiri'

class CCRExportTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('records', '_id')
  end

  test "Checking CCR XML Schema Validation" do

    record = Record.find('4dcbecdb431a5f5878000004')

    xml = HealthDataStandards::Export::CCR.export(record)

    #... if we have a CCR XSD file check if it is a valid CCR XML file
    if (File.exists?("config/ccr.xsd"))
      #todo: Perform XML Schema validation
    else
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      puts "Cypress Unit Test Schema File Absent"
      puts "There currently is not a CCR Schema file setup in your Cypress instance"
      puts "In order to support CCR Schema validation in the unit tests, you should purchase"
      puts "a CCR Schema file from the ASTM website http://www.astm.org/Standards/E2369.htm"
      puts "and put your ASTM CCR Schema file in the file system directory under config/ccr.xsd"
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    end
  end
=begin

  test "Validating CCR XML Data Generation" do
    record = Record.find('4dcbecdb431a5f5878000004')

    doc = Nokogiri::XML(HealthDataStandards::Export::CCR.export(record))
    doc.root.add_namespace_definition('ccr', 'urn:astm-org:CCR')
    # registration information
    assert_equal 'Rosa', doc.at_xpath('//ccr:Actors/ccr:Actor/ccr:Person/ccr:Name/ccr:CurrentName/ccr:Given').text
    assert_equal 'Vasquez', doc.at_xpath('//ccr:Actors/ccr:Actor/ccr:Person/ccr:Name/ccr:CurrentName/ccr:Family').text
    assert_equal 'Female', doc.at_xpath('//ccr:Actors/ccr:Actor/ccr:Person/ccr:Gender/ccr:Text').text
    assert_equal '1980-12-11T18:50:14Z', doc.at_xpath('//ccr:Actors/ccr:Actor/ccr:Person/ccr:DateOfBirth/ccr:ExactDateTime').text

    # problems
    assert_equal '160603005', doc.at_xpath('//ccr:Problems/ccr:Problem/ccr:Description/ccr:Code/ccr:Value').text
    # vital sign
    assert_equal '225171007', doc.at_xpath('//ccr:VitalSigns/ccr:Result/ccr:Description/ccr:Code/ccr:Value').text
    # lab results
    assert_equal '439958008', doc.at_xpath('//ccr:Results/ccr:Result/ccr:Description/ccr:Code/ccr:Value').text
    # procedure
    assert_equal '171055003', doc.at_xpath('//ccr:Procedures/ccr:Procedure/ccr:Description/ccr:Code/ccr:Value').text
    # encounter
    assert_equal '99201', doc.at_xpath('//ccr:Encounters/ccr:Encounter/ccr:Description/ccr:Code/ccr:Value').text
    # allergy
    assert_equal '70618', doc.at_xpath('//ccr:Alerts/ccr:Alert/ccr:Description/ccr:Code/ccr:Value').text
    # medication
    assert_equal '105075', doc.at_xpath('//ccr:Medications/ccr:Medication/ccr:Product/ccr:BrandName/ccr:Code/ccr:Value').text
    # immunization
    assert_equal '854931', doc.at_xpath('//ccr:Immunizations/ccr:Immunization/ccr:Product/ccr:BrandName/ccr:Code/ccr:Value').text
  end

=end
end
