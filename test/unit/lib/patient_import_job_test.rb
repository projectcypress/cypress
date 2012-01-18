require 'test_helper'
require 'fileutils'

class PatientImportJobTest < ActiveSupport::TestCase
  def test_perform
    patient_count = Record.count
    
    # Part of the import job is deleting the temp file it's passed so we'll make and use a copy here too
    c32_zip_path = "test/fixtures/records/test_c32s_#{Time.now.to_i}.zip"
    FileUtils.cp 'test/fixtures/records/test_c32s.zip', c32_zip_path
    
    
    pij = Cypress::PatientImportJob.new(UUID.generate,
      'zip_file_location' => File.absolute_path(c32_zip_path),
      'test_id' => '4def93dd4f85cf8968000006')
    pij.perform
    
    assert_equal (patient_count + 2), Record.count
  end
end