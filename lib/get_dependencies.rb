module Cypress
  class GetDependencies

    def self.get_dependencies(bundle_id)
      deps = Hash.new
      env = Bundler::environment

      bundle = Mongoid.database['bundles'].find({'_id' => bundle_id}).first
      deps["Measures"] = 'v' + bundle['version']
      deps["Health-Data-Standards"] = 'v' + env.specs.to_hash["health-data-standards"].first.version.to_s
      deps["Quality-Measure-Engine"]= 'v' + env.specs.to_hash["quality-measure-engine"].first.version.to_s
      deps["Master Patient List"] = APP_CONFIG["mpl_version"]
      
      return deps
    end

    def self.version()
      return APP_CONFIG["version"]
    end
    
  end
end