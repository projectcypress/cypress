module Cypress
  class GetDependencies

    def self.get_dependencies(bundle_id)
      deps = Hash.new
      env = Bundler::environment

      measure_bundle = Mongoid.database['bundles'].find({'_id' => bundle_id}).first
      mpl_bundle = Mongoid.database['bundles'].find({'name' => 'Meaningful Use Stage 1 Test Deck'}).first
      deps["Measures"] = 'v' + measure_bundle['version']
      deps["Master Patient List"] = 'v' + mpl_bundle['version']
      deps["Health-Data-Standards"] = 'v' + env.specs.to_hash["health-data-standards"].first.version.to_s
      deps["Quality-Measure-Engine"]= 'v' + env.specs.to_hash["quality-measure-engine"].first.version.to_s

      return deps
    end

    def self.version()
      return APP_CONFIG["version"]
    end
    
  end
end