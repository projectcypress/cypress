# yes this is a bit ugly as it is aliasing The bundle class but it
# works for now until we can truley unify these items accross applications
Bundle = HealthDataStandards::CQM::Bundle
class Bundle
  has_many :products, :dependent => :destroy

  field :deprecated, type: Boolean, default: false

  scope :available, -> { where(:deprecated.ne => true) }

  def results
    HealthDataStandards::CQM::PatientCache.where(bundle_id: id, 'value.test_id' => nil)
                                          .order_by(['value.last', :asc])
  end

  def title
    return super unless deprecated?
    self[:title] + ' (Deprecated)'
  end

  def deprecate
    results.destroy
    FileUtils.rm(mpl_path) if File.exist?(mpl_path)
    update_attribute(:deprecated, true)
  end

  def destroy
    results.destroy
    Product.where(bundle_id: id).destroy_all
    FileUtils.rm(mpl_path) if File.exist?(mpl_path)
    delete
  end

  def default_negation_codes
    ApplicationController.helpers.config_for_version(version).default_negation_codes
  end

  # start data offset is the time in seconds to move data forward the number of year specified in config file
  def start_date_offset
    offset_years = ApplicationController.helpers.config_for_version(version).start_date_offset
    (Time.at(measure_period_start).in_time_zone + offset_years.year).to_i - measure_period_start
  end

  def qrda_version
    ApplicationController.helpers.config_for_version(version).qrda_version
  end

  def qrda3_version
    ApplicationController.helpers.config_for_version(version).qrda3_version
  end

  def cms_schematron
    ApplicationController.helpers.config_for_version(version).schematron
  end

  def modified_population_labels
    ApplicationController.helpers.config_for_version(version).modified_population_labels
  end

  def mpl_path
    File.join(Rails.root, 'tmp', 'cache', "bundle_#{id}_mpl.zip")
  end

  def mpl_status
    if File.exist?(mpl_path)
      :ready
    elsif MplDownloadCreateJob.trackers.where(options: { bundle_id: id.to_s }, :status.in => [:queued, :working]).count > 0
      :building
    else
      :unbuilt
    end
  end

  def mpl_prepare
    if mpl_status == :unbuilt
      MplDownloadCreateJob.perform_later(id.to_s)
      :building
    else
      mpl_status
    end
  end

  def major_version
    version.split('.')[0]
  end

  def update_default
    unless version == Settings.current.default_bundle
      Bundle.where(active: true).update_all(active: false)
      self.active = true
      save!
      Bundle.find_by(id: id).active = true
      Settings.current.update(default_bundle: version)
    end
  end

  def self.default
    find_by(active: true)
  rescue
    most_recent
  end

  def self.most_recent
    where(version: pluck(:version).max_by { |v| v.split('.').map(&:to_i) }).first
  end

  def self.first
    raise 'Do not use Bundle.first as there may be multiple bundles and order is not guaranteed.'
  end
end
