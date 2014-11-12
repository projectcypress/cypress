module Cypress
  class GetDependencies

    def self.get_dependencies(bundle_id=nil)
      deps = Hash.new
      env  = Bundler::environment

      measure_bundle = 'Unknown'
      if bundle_id.nil?
        measure_bundle = Bundle.last
      else
        measure_bundle = Bundle.find(bundle_id)
      end



      deps["Measures"] = 'v' + measure_bundle['version']
      deps["Master Patient List"] = 'v'
      deps["Health-Data-Standards"] = 'v' + env.specs.to_hash["health-data-standards"].first.version.to_s
      deps["Quality-Measure-Engine"]= 'v' + env.specs.to_hash["quality-measure-engine"].first.version.to_s

      return deps
    end

    def self.version()
      return APP_CONFIG["version"]
    end

  end
end
