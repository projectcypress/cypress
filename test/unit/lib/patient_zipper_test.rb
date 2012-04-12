require 'test_helper'
require 'fileutils'

class PatientZipperTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('records','_id')
    @patients = Record.where("gender" => "F")
  end
  
  test "Should create valid c32 file" do
    format = :c32
    filename = "pTest-#{Time.now.to_i}.c32.zip"
    file = Tempfile.new(filename)
    
    Cypress::PatientZipper.zip(file,@patients,format)
    file.close
    count = 0
    Zip::ZipFile.foreach(file.path) do |zip_entry|
        if zip_entry.name.include?('.xml') && !zip_entry.name.include?('__MACOSX')
          doc = Nokogiri::XML(zip_entry.get_input_stream) do |config|
            config.strict
          end
          doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
          patient = HealthDataStandards::Import::C32::PatientImporter.instance.parse_c32(doc)
          assert patient.first == "Rosa" || patient.first == "Selena" ,       "Zip file contains wrong records"
          assert patient.last == "Vasquez" || patient.last == "Lotherberg" ,  "Zip file contains wrong records"
          count += 1
        end
    end
    File.delete(file.path)
    assert count == 2 , "Zip file has wrong number of records"
  end

  test "Should create valid html file" do
    format = :html
    filename = "pTest-#{Time.now.to_i}.html.zip"
    file = Tempfile.new(filename)
    
    Cypress::PatientZipper.zip(file,@patients,format)
    file.close

    count = 0
    Zip::ZipFile.foreach(file.path) do |zip_entry|
        if zip_entry.name.include?('.html') && !zip_entry.name.include?('__MACOSX')
          doc = Nokogiri::HTML(zip_entry.get_input_stream) do |config|
            config.strict
          end
          title = doc.at_css("head title").to_s
          assert title.include?('Selena Lotherberg') || title.include?('Rosa Vasquez') , "Zip file contains wrong records"
          count += 1
        end
    end
    File.delete(file.path)
    assert count == 2 , "Zip file has wrong number of records"
  end
  
  test "Should create valid ccr file" do
    format = :ccr
    filename = "pTest-#{Time.now.to_i}.ccr.zip"
    file = Tempfile.new(filename)

    Cypress::PatientZipper.zip(file,@patients,format)
    file.close
    count = 0
    Zip::ZipFile.foreach(file.path) do |zip_entry|
        if zip_entry.name.include?('.xml') && !zip_entry.name.include?('__MACOSX')
          doc = Nokogiri::XML(zip_entry.get_input_stream) do |config|
            config.strict
          end
          doc.root.add_namespace_definition('ccr', 'urn:astm-org:CCR')
          patient = HealthDataStandards::Import::CCR::PatientImporter.instance.parse_ccr(doc)
          assert patient.first == "Rosa" || patient.first == "Selena" ,       "Zip file contains wrong records"
          assert patient.last == "Vasquez" || patient.last == "Lotherberg" ,  "Zip file contains wrong records"
          count += 1
        end
    end
    File.delete(file.path)
    assert count == 2 , "Zip file has wrong number of records"
  end
  
  test "Should create valid csv file" do
    filename = "pTest-#{Time.now.to_i}.csv"
    file = Tempfile.new(filename)
    Cypress::PatientZipper.flat_file(file,@patients)
    
    lines = file.readlines
    columns = lines[0]
    columns = columns.split(',')
    assert lines.count   == 3, "CSV file has wrong number of records"
    assert columns.count == 7, "CSV file has wrong number of columns"
    #contents = file.read
    #correct_contents = "patient_id,first name,last name,gender,race,ethnicity,birthdate\n19,Selena,Lotherberg,F,Other Race,Hispanic or Latino,03/31/1997\n20,Rosa,Vasquez,F,Other Race,Hispanic or Latino,08/05/1940\n"
    #assert correct_contents == contents, "CSV contents not correct: \n #{correct_contents}"
    file.close
    File.delete(file.path)
  end
  
end
