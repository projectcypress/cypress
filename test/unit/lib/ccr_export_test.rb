ENV["RAILS_ENV"] = "test"

require 'test_helper'
require 'builder'
require 'nokogiri'

class CCRExportTest < ActiveSupport::TestCase

  setup do
  end

  test "Checking CCR XML Schema Validation" do

    # perform schema validation of patients by iterating over all of the JSON record fixutes 
    # in the test/fixtures/records/ directory, creating CCR XML, and then running the generated
    # CCR against an ASTM CCR Schema file if present
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', 'records', '*.json')).each do |json_fixture_file|

      # grab each JSON fixture
      fixture_json = JSON.parse(File.read(json_fixture_file))
      patient_record = Record.new(fixture_json)

      # load the XML associated with that fixture into Nokogiri
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      doc = Nokogiri::XML(patient_record.to_ccr(xml))

      # if we have a CCR XSD file check if it is a valid CCR XML file
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

  end

  test "Validating CCR XML Data Generation" do

    # load Rosa's raw data into the Record model
    fixture_json = JSON.parse(File.read("test/fixtures/records/rosa.json"))
    patient_record = Record.new(fixture_json)

    # load the XML into Nokogiri to allow XPath expressions to be run against it
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    doc = Nokogiri::XML(patient_record.to_ccr(xml))
    doc.root.add_namespace_definition('ccr', 'urn:astm-org:CCR')

    # Perform data checks against elements
    doc.xpath('//ccr:Actors/ccr:Actor/ccr:Person/ccr:Name/ccr:CurrentName/ccr:Given').each do |first_name|
      assert_equal 'Rosa', first_name.text
    end
    doc.xpath('//ccr:Actors/ccr:Actor/ccr:Person/ccr:Name/ccr:CurrentName/ccr:Family').each do |last_name|
      assert_equal 'Vasquez', last_name.text
    end
    doc.xpath('//ccr:Actors/ccr:Actor/ccr:DateOfBirth/ccr:Gender/ccr:Text').each do |gender|
      assert_equal 'Female', gender.text
    end
    doc.xpath('//ccr:Actors/ccr:Actor/ccr:DateOfBirth/ccr:ExactDateTime').each do |date_of_birth|
      assert_equal '1980-12-11T18:50:14Z', date_of_birth.text
    end
  end

end