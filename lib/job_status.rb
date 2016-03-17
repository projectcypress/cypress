module Job
  module Status
    extend ActiveSupport::Concern

    included do
      before_enqueue do |job|
        job.tracker.queued
      end

      around_perform do |job, block|
        job.tracker.working
        begin
          block.call
          job.tracker.finished
          job.tracker.destroy
        rescue Exception => e
          tracker.failed e
        end
      end

      def tracker
        @tracker ||= Tracker.find_or_create_by(job_id: @job_id, job_class: self.class.to_s)
      end
    end

    class_methods do
      def tracker_for_job(job_id)
        Tracker.where(job_id: job_id, job_class: to_s)
      end

      def trackers
        Tracker.where(job_class: to_s)
      end
    end
  end
end
