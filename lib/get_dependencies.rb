module Cypress
  class GetDependencies

    def self.get_dependencies()
      deps = Hash.new
      env = Bundler::environment
      deps["Health-Data-Standards"] = env.specs.to_hash["health-data-standards"].first.version.to_s
      #deps["Health-Data-Standards"] = info.first.version.to_s
      #info = env.specs.to_hash["quality-measure-engine"].first
      deps["Quality-Measure-Engine"] = env.specs.to_hash["quality-measure-engine"].first.version.to_s
      return deps
    end

    def self.version()
      return APP_CONFIG["version"]
    end


    
  end
end