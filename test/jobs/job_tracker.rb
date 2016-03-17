require 'test_helper'

class JobStatusTest < ActiveJob::TestCase
  class FailedJob < ActiveJob::Base
    include Job::Status
    def perform
      fail 'Failed'
    end
  end

  class PassingJob < ActiveJob::Base
    include Job::Status
    def perform
    end
  end

  test 'should be able to track queued jobs' do
    assert_equal 0, PassingJob.trackers.count, 'Should be 0 jobs being tracked'
    PassingJob.perform_later
    assert_equal 1, PassingJob.trackers.count, 'Should be 1 job being tracked'
    assert_equal :queued, PassingJob.trackers.first.status, 'job tracker status should be :queued'
    assert_equal 0, FailedJob.trackers.count, 'Should be 0 jobs being tracked for failed jobs'
  end

  test 'should remove trackers for completed jobs' do
    assert_equal 0, PassingJob.trackers.count, 'Should be 0 jobs being tracked'
    perform_enqueued_jobs do
      PassingJob.perform_later
      assert_equal 0, PassingJob.trackers.count, 'tracker should have been removed for completed job'
    end
  end

  test 'should be able to track failed jobs' do
    assert_equal 0, FailedJob.trackers.count, 'Should be 0 jobs being tracked'
    perform_enqueued_jobs do
      FailedJob.perform_later
      assert_equal 1, FailedJob.trackers.count, 'tracker should have set status to failed '
      assert_equal :failed, FailedJob.trackers.first.status, 'job tracker status should be :failed'
    end
  end
end
