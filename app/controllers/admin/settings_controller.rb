module Admin
  class SettingsController < AdminController
    add_breadcrumb 'Admin', :admin_path

    def show
      redirect_to admin_path(anchor: 'application_settings')
    end

    def edit
      add_breadcrumb 'Edit Settings', :edit_settings_path
      render locals: {
        banner_message: Settings.banner_message,
        smtp_settings: Rails.application.config.action_mailer.smtp_settings,
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
      write_banner_message(settings)
      write_mailer_settings(settings)
      write_mode_settings
    end

    def write_banner_message(settings)
      sub_yml_setting('banner_message', settings['banner_message'])
      Settings[:banner_message] = settings['banner_message']
    end

    def write_mailer_settings(settings)
      settings.each_pair do |key, val|
        key_str = key.to_s
        next unless key_str.include? 'mailer_'
        val = val == '' ? nil : val.to_i if key_str == 'mailer_port'
        sub_yml_setting(key_str, val)
        env_config_key = key_str.sub('mailer_', '').to_sym
        Rails.application.config.action_mailer.smtp_settings[env_config_key] = val
      end
    end

    def write_mode_settings
      sub_yml_setting('auto_approve', Settings[:auto_approve])
      sub_yml_setting('ignore_roles', Settings[:ignore_roles])
      sub_yml_setting('default_role', Settings[:default_role])
      sub_yml_setting('enable_debug_features', Settings[:enable_debug_features])
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
