require 'test_helper'
require 'patient_import_job'

class PatientImportJobTest < ActiveSupport::TestCase
  def test_perform
    patient_count = Record.count
    pij = Cypress::PatientImportJob.new(UUID.generate, 'zip_file_location' => 'test/fixtures/test_c32s.zip')
    pij.perform
    assert_equal (patient_count + 2), Record.count
  end
end