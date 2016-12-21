# When this module is called from a test, make sure it is wrapped in Faker. Otherwise you will have problems with travis.
module Cypress
  class AppConfig
    def self.[](key)
      # Allow accessing app config during app init, before Rails.cache exists
      if Rails.cache.nil?
        if @init_app_config.nil?
          @init_app_config = YAML.load(ERB.new(File.read("#{Rails.root}/config/cypress.yml")).result)
        end
        return @init_app_config[key]
      end

      Rails.cache.fetch('config_values') do
        YAML.load(ERB.new(File.read("#{Rails.root}/config/cypress.yml")).result)
      end[key]
    end

    # This method writes a new value to a setting in cypress.yml
    # Note that as of now this is brittle, using regex-based string substitution to overwrite values, and it is only designed to work on top level
    # (not nested) key-value pairs of type String, Symbol, Numeric, TrueClass, and FalseClass. Any value that that does not describe will require
    # further custom string substitution.
    # The ideal way to do this would be to load the YML into a hash, update the values, and then dump the hash back into YML. The current problem
    # with that method is that it does not preserve comments.
    # -tstrassner
    def self.[]=(key, val)
      yml_text = File.read("#{Rails.root}/config/cypress.yml")
      sub_string = /#{key}:(.*?)\n/
      if val.is_a? String
        yml_text.sub!(sub_string, "#{key}: \"#{val}\"\n")
      elsif val.is_a? Symbol
        yml_text.sub!(sub_string, "#{key}: :#{val}\n")
      else
        yml_text.sub!(sub_string, "#{key}: #{val}\n")
      end
      File.open("#{Rails.root}/config/cypress.yml", 'w') { |file| file.puts yml_text }

      # Allow setting app config during app init, before Rails.cache exists
      if Rails.cache.nil?
        @init_app_config = YAML.load(ERB.new(File.read("#{Rails.root}/config/cypress.yml")).result)
      else
        Rails.cache.delete('config_values')
      end
    end
  end
end
