module VersionConfigHelper
  def config_for_version(bundle_version = Cypress::AppConfig['default_bundle'])
    versions = Cypress::AppConfig['version_config'].keys.map { |k| { spec: Gem::Dependency.new('', k), key: k } }.sort_by { |b| b[:key] }.reverse
    version = versions.select { |v| v.spec.match?('', bundle_version) }.first || { key: Cypress::AppConfig['version_config'].keys.first }
    Cypress::AppConfig['version_config'][version[:key]]
  end
end
