class MplDownloadCreateJob < ActiveJob::Base
  include Job::Status
  after_enqueue do |job|
    tracker = job.tracker
    tracker.options['bundle_id'] = job.arguments[0]
    tracker.save
  end
  def perform(bundle_id)
    tracker.log('Creating Download')
    bundle = Bundle.find(bundle_id)
    path = File.join(Rails.root, 'tmp', 'cache', 'bundle_download', bundle.id.to_s)
    Cypress::CreateDownloadZip.bundle_directory(bundle, path)
    zfg = ZipFileGenerator.new(path, bundle.mpl_path)
    zfg.write
    FileUtils.rm_rf(path)
  end
end
