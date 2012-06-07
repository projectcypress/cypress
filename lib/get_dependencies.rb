module Cypress
  class GetDependencies

    def self.get_dependencies()
      deps = Hash.new
      env = Bundler::environment
      
      deps["Measures"] = APP_CONFIG["measures_version"]
      deps["Health-Data-Standards"] = 'v' + env.specs.to_hash["health-data-standards"].first.version.to_s
      deps["Quality-Measure-Engine"]= 'v' + env.specs.to_hash["quality-measure-engine"].first.version.to_s

      return deps
    end

    def self.version()
      return APP_CONFIG["version"]
    end


    
  end
end