class BundleUploadJob < ActiveJob::Base
  include Job::Status
  include CypressYaml
  DEFAULT_OPTIONS = { delete_existing: false, update_measures: false, exclude_results: false }.freeze
  after_enqueue do |job|
    tracker = job.tracker
    tracker.options['original_filename'] = job.arguments[1]
    tracker.save
  end
  def perform(file, _original_file_name, options = {})
    tracker.log('Importing')
    unless File.extname(file) == '.zip'
      # tracker.fail 'Bundle must be a Zip file'
      # tracker.log("file name #{file}")
      return
    end
    bundle_file = File.new(file)
    options = DEFAULT_OPTIONS.merge(options)
    already_have_default = Bundle.where(active: true).exists?

    importer = HealthDataStandards::Import::Bundle::Importer
    @bundle = importer.import(bundle_file, options)

    if already_have_default
      @bundle.active = false
      @bundle.save!
    else
      APP_CONFIG['default_bundle'] = @bundle.version
      sub_yml_setting('default_bundle', APP_CONFIG['default_bundle'])
    end
  end
end
