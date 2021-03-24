module VersionConfigHelper
  def config_for_version(bundle_version = Settings.current.default_bundle)
    versions = APP_CONSTANTS['version_config'].keys.map { |k| { spec: Gem::Dependency.new('', k), key: k } }.sort_by { |b| b[:key] }.reverse
    version = versions.select { |v| v.spec.match?('', bundle_version) }.first || { key: APP_CONSTANTS['version_config'].keys.first }
    APP_CONSTANTS['version_config'][version[:key]]
  end

  def possible_qrda_uploaders
    uploaders = []
    APP_CONSTANTS['version_config'].each do |_bundle_key, version_config|
      reporting_year = version_config['schematron'][0, 4].to_i + 1
      uploaders << QrdaUpload.new(validator: "HL7 QRDA Category I validator for #{reporting_year} (#{version_config['qrda_version']})",
                                  path: "/qrda_validation/#{reporting_year}/qrdaI/hl7")
      uploaders << QrdaUpload.new(validator: "HL7 QRDA Category III validator for #{reporting_year} (#{version_config['qrda3_version']})",
                                  path: "/qrda_validation/#{reporting_year}/qrdaIII/hl7")
      unless version_config['CMSQRDA1HQRSchematronValidator_warnings']
        uploaders << QrdaUpload.new(validator: "CMS QRDA Category I validator for #{reporting_year}",
                                    path: "/qrda_validation/#{reporting_year}/qrdaI/cms")
      end
      unless version_config['CMSQRDA3SchematronValidator_warnings']
        uploaders << QrdaUpload.new(validator: "CMS QRDA Category III validator for #{reporting_year}",
                                    path: "/qrda_validation/#{reporting_year}/qrdaIII/hl7")
      end
    end
    uploaders
  end
end
