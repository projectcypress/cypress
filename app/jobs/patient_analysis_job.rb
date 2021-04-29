# frozen_string_literal: true

class PatientAnalysisJob < ApplicationJob
  include Job::Status
  include PatientAnalysisHelper

  after_enqueue do |job|
    tracker = job.tracker
    tracker.options['bundle_id'] = job.arguments[0]
    tracker.options['vendor_id'] = job.arguments[1]
    tracker.save
  end

  def perform(bundle_id, vendor_id)
    bundle = Bundle.find(bundle_id)
    vendor = Vendor.find(vendor_id)
    tracker.log('Analyzing')
    vendor.vendor_patient_analysis[bundle_id] = generate_analysis(vendor.patients, nil, bundle)
    vendor.save
  end
end
