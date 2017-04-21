module VersionConfigHelper
  def config_for_version(bundle_version = Settings.current.default_bundle)
    versions = APP_CONSTANTS['version_config'].keys.map { |k| { spec: Gem::Dependency.new('', k), key: k } }.sort_by { |b| b[:key] }.reverse
    version = versions.select { |v| v.spec.match?('', bundle_version) }.first || { key: APP_CONSTANTS['version_config'].keys.first }
    APP_CONSTANTS['version_config'][version[:key]]
  end
end
