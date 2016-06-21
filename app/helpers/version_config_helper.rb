module VersionConfigHelper
	def config_for_version(bundle_version=APP_CONFIG.default_bundle)
		versions = APP_CONFIG.version_config.keys.map{|k| {spec:Gem::Dependency.new('', k), key: k}}.sort.reverse
		version = versions.select {|v| v.spec.match?('', bundle_version)}.first|| {key:APP_CONFIG.version_config.keys.first}
		APP_CONFIG.version_config[version[:key]]
	end
end