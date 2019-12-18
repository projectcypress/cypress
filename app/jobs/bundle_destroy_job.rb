class BundleDestroyJob < ApplicationJob
  include Job::Status
  after_enqueue do |job|
    tracker = job.tracker
    tracker.options['bundle_title'] = job.arguments[1]
    tracker.save
  end
  def perform(bundle_id, bundle_title)
    tracker.log("Removing #{bundle_title}")
    bundle = Bundle.find(bundle_id)
    bundle.destroy

    # clear this cache just in case it's pointing to the bundle just deprecated
    Rails.cache.delete('any_installed_bundle')
  end
end
