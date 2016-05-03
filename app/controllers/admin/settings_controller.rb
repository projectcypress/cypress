module Admin
  class SettingsController < ApplicationController
    add_breadcrumb 'Admin', :admin_path
    before_action -> { fail CanCan::AccessDenied.new, 'Forbidden' unless current_user.has_role? :admin }

    def show
      redirect_to admin_path(anchor: 'application_settings')
    end

    def edit
      add_breadcrumb 'Edit', :edit_settings_path
      smtp_settings = Rails.application.config.action_mailer.smtp_settings
      render locals: {
        banner_message: Settings.banner_message,
        address: smtp_settings.address,
        port: smtp_settings.port,
        domain: smtp_settings.domain,
        user_name: smtp_settings.user_name,
        password: smtp_settings.password
      }
    end

    def update
      write_settings_to_yml(params)
      redirect_to admin_path(anchor: 'application_settings')
    end

    private

    def write_settings_to_yml(settings)
      yaml_text = File.read("#{Rails.root}/config/cypress.yml")
      write_banner_message(settings, yaml_text)
      write_mailer_settings(settings, yaml_text)
      File.open("#{Rails.root}/config/cypress.yml", 'w') { |file| file.puts yaml_text }
    end

    def write_banner_message(settings, yaml_text)
      yaml_text.sub!(/^\s*banner_message: "(.*)"/, "banner_message: \"#{settings['banner_message']}\"")
      Settings[:banner_message] = settings['banner_message']
    end

    def write_mailer_settings(settings, yaml_text)
      settings.each_pair do |key, val|
        key_str = key.to_s
        next unless key_str.include? 'mailer_'
        if key_str == 'mailer_port'
          val = val == '' ? nil : val.to_i
          yaml_text.sub!(/^\s*#{key_str}: (.*)/, "#{key_str}: #{val}")
        else
          yaml_text.sub!(/^\s*#{key_str}: "(.*)"/, "#{key_str}: \"#{val}\"")
        end
        env_config_key = key_str.sub('mailer_', '').to_sym
        Rails.application.config.action_mailer.smtp_settings[env_config_key] = val
      end
    end

    def valid_port?(port_str)
      true if (1..65_535).cover?(port_str.to_i)
    end
  end
end
