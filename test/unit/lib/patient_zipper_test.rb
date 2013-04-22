require 'test_helper'
require 'fileutils'

class PatientZipperTest < ActiveSupport::TestCase

  setup do

    collection_fixtures('records','_id','bundle_id')
    @patients = Record.where("gender" => "F")
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
          count += 1 
        end
    end
    File.delete(file.path)
    assert count == 5 , "Zip file has wrong number of records should be 5 , was #{count}"
  end
  
 

  test "Should create valid qrda file" do
    format = :qrda
    filename = "pTest-#{Time.now.to_i}.qrda.zip"
    file = Tempfile.new(filename)
 
    Cypress::PatientZipper.zip(file,@patients,format)
    file.close

    count = 0
    Zip::ZipFile.foreach(file.path) do |zip_entry|
        
         if zip_entry.name.include?('.xml') && !zip_entry.name.include?('__MACOSX')
          doc = Nokogiri::XML(zip_entry.get_input_stream) do |config|
            config.strict
          end
          count += 1
        end
    end
    File.delete(file.path)
    assert count == 5 , "Zip file has wrong number of records should be 5 , was #{count}"
  end

  
end
