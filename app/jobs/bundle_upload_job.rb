class BundleUploadJob < ApplicationJob
  include Job::Status
  DEFAULT_OPTIONS = { delete_existing: false, update_measures: false, exclude_results: false }.freeze
  after_enqueue do |job|
    tracker = job.tracker
    tracker.options['original_filename'] = job.arguments[1]
    tracker.save
  end
  def perform(file, original_file_name, options = {})
    tracker.log('Importing')
    raise('Bundle must have extension .zip') unless File.extname(original_file_name) == '.zip'

    bundle_file = File.new(file)
    options = DEFAULT_OPTIONS.merge(options)
    already_have_default = Bundle.where(active: true).exists?

    importer = Cypress::CqlBundleImporter
    @bundle = importer.import(bundle_file, options)

    if already_have_default
      @bundle.active = false
      @bundle.save!
    else
      Settings.current.default_bundle = @bundle.version
    end

    # create master patient list
    @bundle.mpl_prepare
  end
end
