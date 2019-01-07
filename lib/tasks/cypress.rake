namespace :cypress do
  namespace :cleanup do
    task :setup => :environment

    desc 'Remove temporary items (such as vendors, tests, etc) from the database, without removing existing users'
    task :database => :setup do
      print 'Cleaning database...'
      Delayed::Job.destroy_all
      before = Vendor.all.count
      Vendor.destroy_all
      diff = before - Vendor.all.count
      Record.destroy_all(:test_id => { '$ne' => nil })
      Artifact.destroy_all
      puts "removed #{diff} Vendors"
    end

    desc 'Get rid of files in tmp/cache'
    task :temp_files => :setup do
      print 'Cleaning temp files...'
      task('tmp:cache:clear').invoke
      Rails.cache.clear
      puts 'done'
    end

    task :all => %i[environment database temp_files]
  end

  namespace :import do
    task :config, %i[config_file environment] => :environment do |_, args|
      if File.exist?(args.config_file)
        # Get rid of the first and last quote on the string, split on all spaces
        # This loads "AUTO_APPROVE=true" "ENABLE_DEBUG_FEATURES="... into the environment
        unless args.environment.nil?
          args.environment[1..-2].split('" "').each do |key_val|
            key_val_split = key_val.split('=')
            # If the value is nil then convert it to empty string in order to satisfy previous setup
            ENV[key_val_split[0]] = (key_val_split[1] || '')
          end
        end
        # Get all of the keys from the Settings model
        settings_keys = Settings.fields.keys
        # Fetch and parse the contents of the yaml config file
        yaml_content = YAML.safe_load(ERB.new(File.read(args.config_file)).result)
        # Filter the yaml content to only contain the keys we store in the database
        yaml_content.select! { |key, _| settings_keys.include? key }
        # Save those keys in the database.
        Settings.current.update(yaml_content)
      end
    end
  end
end
