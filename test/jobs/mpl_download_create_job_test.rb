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
