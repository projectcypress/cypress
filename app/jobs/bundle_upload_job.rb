class BundleUploadJob < ApplicationJob
  include Job::Status
  DEFAULT_OPTIONS = { delete_existing: false, update_measures: false, exclude_results: false }.freeze
  after_enqueue do |job|
    tracker = job.tracker
    tracker.options['original_filename'] = job.arguments[1]
    tracker.save
  end
  def perform(file, original_file_name)
    tracker.log('Importing')
    raise('Bundle must have extension .zip') unless File.extname(original_file_name) == '.zip'

    bundle_file = File.new(file)
    already_have_default = Bundle.where(active: true).exists?

    importer = Cypress::CqlBundleImporter
    @bundle = importer.import(bundle_file, tracker)

    if already_have_default
      @bundle.active = false
      @bundle.save!
    else
      Settings.current.update(default_bundle: @bundle.version)
    end
    if Settings.current.default_code_systems.empty?
      # create original code system defaults
      Settings.current.update(default_code_systems: calculate_default_code_options(@bundle))
    else
      # identify additional code system information
      diff_hash = create_code_system_diff(Settings.current.default_code_systems, calculate_default_code_options(@bundle))
      append_code_system_diff(diff_hash)
    end

    # create master patient list
    @bundle.mpl_prepare
  end

  private

  def calculate_default_code_options(bundle)
    # entry.qdmCategory -> [ordered code system list]
    code_system_hash = {}
    bundle.measures.each do |m|
      m.source_data_criteria.each do |sdc|
        code_system_hash[sdc.qdmCategory] = [] unless code_system_hash.key?(sdc.qdmCategory)
        vs = ValueSet.where(oid: sdc.codeListId).first
        if vs
          concept_code_systems = vs.concepts.map(&:code_system_oid)
          code_system_hash[sdc.qdmCategory].concat(concept_code_systems)
        end
      end
    end
    code_system_hash.each_value(&:uniq!)
    code_system_hash
  end

  def create_code_system_diff(old_code_systems, new_code_systems)
    diff_hash = {}
    new_code_systems.each_key do |key|
      diff_hash[key] = if old_code_systems[key]
                         # only the newly added code_system options
                         new_code_systems[key] - old_code_systems[key]
                       else
                         new_code_systems[key]
                       end
    end
    diff_hash
  end

  def append_code_system_diff(diff_hash)
    dcs_hash = Settings.current.default_code_systems
    # append additional code system information to code system defaults
    diff_hash.each_key do |key|
      # create empty array if necessary
      dcs_hash[key] = [] unless Settings.current.default_code_systems.key?(key)
      dcs_hash[key].concat(diff_hash[key])

      # TODO: check for any concurrency issues of user working with vendor preferences while
      #       bundle is being added
      # TODO: check that code system formation works for drc

      # append additional code system information to all non-empty vendor preferences
      Vendor.all.each do |v|
        next if v.preferred_code_systems.empty?

        v.preferred_code_systems[key] = [] unless v.preferred_code_systems.key?(key)
        v.preferred_code_systems[key].concat(diff_hash[key])
        v.save
      end
    end
    Settings.current.update(default_code_systems: dcs_hash)
  end
end
