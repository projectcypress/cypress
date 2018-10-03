require 'test_helper'

class MplDownloadCreateJobTest < ActiveJob::TestCase
  setup do
    @bundle = FactoryBot.create(:static_bundle)
    # Clean up MPL before and after running for consistency
    FileUtils.rm_rf(@bundle.mpl_path)
  end

  teardown do
    FileUtils.rm_rf(@bundle.mpl_path)
  end

  def test_enqueue_mpl_create_job
    assert_enqueued_jobs 0

    assert_enqueued_jobs 1 do
      assert :building, @bundle.mpl_prepare
    end
  end

  def test_running_mpl_job_success
    perform_enqueued_jobs do
      assert :building, @bundle.mpl_prepare
      assert_performed_jobs 1
      assert :ready, @bundle.mpl_status
      assert File.exist?(@bundle.mpl_path)
      Zip::ZipFile.open(@bundle.mpl_path) do |zip_file|
        assert_operator zip_file.entries.count, :>, 2
        entry_names = zip_file.entries.collect(&:name)
        @bundle.patients.each do |patient|
          patient_file_name = "#{patient.givenNames.join('_')}_#{patient.familyName}".delete("'").tr(' ', '_')
          assert_includes entry_names, "html_records/#{patient_file_name}.html"
          assert_includes entry_names, "qrda_records/#{patient_file_name}.xml"
        end
      end
    end
  end

  def test_multiple_enqueue_does_not_create_multiple_jobs
    assert_enqueued_jobs 0
    assert :building, @bundle.mpl_prepare
    assert_enqueued_jobs 1
    assert :building, @bundle.mpl_prepare
    assert_enqueued_jobs 1
  end
end
