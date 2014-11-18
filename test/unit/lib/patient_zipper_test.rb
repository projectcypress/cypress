require 'test_helper'
require 'fileutils'

class PatientZipperTest < ActiveSupport::TestCase

  setup do

    collection_fixtures('records','_id','bundle_id')
    collection_fixtures('bundles', '_id')
    collection_fixtures('tests', '_id')
    collection_fixtures('test_executions', '_id')
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
    assert count == 6 , "Zip file has wrong number of records should be 6 , was #{count}"
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
    assert count == 6 , "Zip file has wrong number of records should be 6 , was #{count}"
  end

  test "should create valid artifact zip" do
    filename = "#{Rails.root}/test/fixtures/artifacts/qrda.zip"
    artifact = Artifact.new(file: File.new(filename))
    te = TestExecution.find("4f6b78971d41c851eb0004aa")
    artifact.test_execution = te

    zip = Cypress::PatientZipper.zip_artifacts(te)

    xml_present = false
    html_present = false
    xml_present = false
    pdf_present = false
    json_present = false
    artifact_zip_present = false
    Zip::ZipFile.foreach(zip.path) do |zip_entry|
      if zip_entry.name.include?('.pdf')
        pdf_present = true
      elsif zip_entry.name.include?('.zip')
        artifact_zip_present = true
      elsif zip_entry.name.include?('/qrda')
        xml_present = true
      elsif zip_entry.name.include?('/html')
        html_present = true
      elsif zip_entry.name.include?('/json')
        json_present = true
      end
    end
    assert_equal pdf_present, true, "PDF not present"
    assert_equal artifact_zip_present, true, "Artifact not present"
    assert_equal html_present, true, "HTML folder not present"
    assert_equal xml_present, true, "QRDA folder not present"
    assert_equal json_present, true, "JSON folder not present"
  end


end
