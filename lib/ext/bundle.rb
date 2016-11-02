# yes this is a bit ugly as it is aliasing The bundle class but it
# works for now until we can truley unify these items accross applications
Bundle = HealthDataStandards::CQM::Bundle
class Bundle
  has_many :products, :dependent => :destroy
  def results
    HealthDataStandards::CQM::PatientCache.where(bundle_id: id, 'value.test_id' => nil)
                                          .order_by(['value.last', :asc])
  end

  def destroy
    results.destroy
    Product.where(bundle_id: id).destroy_all
    FileUtils.rm(mpl_path) if File.exist?(mpl_path)
    delete
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

  def major_version
    version.split('.')[0]
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
