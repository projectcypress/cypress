class BundleUploadJob < ActiveJob::Base
  DEFAULT_OPTIONS = { delete_existing: false, update_measures: false, exclude_results: false }
  def perform(file, options = {})
    unless File.extname(file) == '.zip'
      #tracker.fail 'Bundle must be a Zip file'
      #tracker.log("file name #{file}")
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
    end
  end

end
