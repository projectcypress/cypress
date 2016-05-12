module Admin
  class SettingsController < ApplicationController
    add_breadcrumb 'Admin', :admin_path
    before_action -> { raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.has_role? :admin }

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
        password: smtp_settings.password,
        mode: ApplicationController.helpers.application_mode,
        mode_settings: ApplicationController.helpers.application_mode_settings,
        roles: %w(User ATL Admin None)
      }
    end

    def update
      update_application_mode params[:mode], params[:custom_options]
      write_settings_to_yml(params)
      redirect_to admin_path(anchor: 'application_settings')
    end

    private

    def write_settings_to_yml(settings)
      yaml_text = File.read("#{Rails.root}/config/cypress.yml")
      write_banner_message(settings, yaml_text)
      write_mailer_settings(settings, yaml_text)
      write_mode_settings(yaml_text)
      File.open("#{Rails.root}/config/cypress.yml", 'w') { |file| file.puts yaml_text }
    end

    def write_banner_message(settings, yaml_text)
      sub_yaml_setting('banner_message', settings['banner_message'], yaml_text)
      Settings[:banner_message] = settings['banner_message']
    end

    def write_mailer_settings(settings, yaml_text)
      settings.each_pair do |key, val|
        key_str = key.to_s
        next unless key_str.include? 'mailer_'
        val = val == '' ? nil : val.to_i if key_str == 'mailer_port'
        sub_yaml_setting(key_str, val, yaml_text)
        env_config_key = key_str.sub('mailer_', '').to_sym
        Rails.application.config.action_mailer.smtp_settings[env_config_key] = val
      end
    end

    def write_mode_settings(yaml_text)
      sub_yaml_setting('auto_approve', Settings[:auto_approve], yaml_text)
      sub_yaml_setting('ignore_roles', Settings[:ignore_roles], yaml_text)
      sub_yaml_setting('default_role', Settings[:default_role], yaml_text)
      sub_yaml_setting('enable_debug_features', Settings[:enable_debug_features], yaml_text)
    end

    def sub_yaml_setting(key, val, yaml_text)
      if val.is_a? String
        yaml_text.sub!(/^\s*#{key}: "(.*)"/, "#{key}: \"#{val}\"")
      elsif val.is_a? Symbol
        yaml_text.sub!(/^\s*#{key}: (.*)/, "#{key}: :#{val}")
      else
        yaml_text.sub!(/^\s*#{key}: (.*)/, "#{key}: #{val}")
      end
    end

    def update_application_mode(mode_name, options = {})
      if mode_name == 'internal'
        ApplicationController.helpers.mode_internal
      elsif mode_name == 'demo'
        ApplicationController.helpers.mode_demo
      elsif mode_name == 'atl'
        ApplicationController.helpers.mode_atl
      elsif mode_name == 'custom'
        ApplicationController.helpers.mode_custom options
      end
    end

    def valid_port?(port_str)
      true if (1..65_535).cover?(port_str.to_i)
    end
  end
end
