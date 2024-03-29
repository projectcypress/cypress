# frozen_string_literal: true

class ChecklistTestSetupJob < ApplicationJob
  queue_as :product_test_setup
  include Job::Status
  def perform(checklist_test)
    # It is not necessary to monitor the status of this job, since this task
    # will be completed on the frontend if the users tries to download
    # criteria results before this has run.
    checklist_test.archive_patients if checklist_test.patient_archive.path.nil?
  end
end
