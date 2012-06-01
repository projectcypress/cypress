module Cypress
  class Version

    def self.current()
      return APP_CONFIG["version"]
    end

    def self.measures()
      return APP_CONFIG["measures_version"]
    end
  end
end 