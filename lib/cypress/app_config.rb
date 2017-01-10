# When this module is called from a test, make sure it is wrapped in Faker. Otherwise you will have problems with travis.
module Cypress
  class AppConfig
    def self.clear
      Rails.cache.delete('config_values') unless Rails.cache.nil?
    end

    def self.[](key)
      # Allow accessing app config during app init, before Rails.cache exists
      # Also check if we are running in non-server mode. If we are then we must not pollute
      # the cache with potentially bad values for app_config
      if Rails.cache.nil? || !ENV['IS_SERVER']
        YAML.load(ERB.new(File.read("#{Rails.root}/config/cypress.yml")).result)[key]
      else
        Rails.cache.fetch('config_values') do
          YAML.load(ERB.new(File.read("#{Rails.root}/config/cypress.yml")).result)
        end[key]
      end
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
      clear
    end
  end
end
