module Admin
  class SettingsController < AdminController
    def show
      redirect_to admin_path(anchor: 'application_settings')
    end

    def edit
      add_breadcrumb 'Edit Settings', :edit_settings_path
      render locals: {
        banner_message: Cypress::AppConfig['banner_message'],
        banner: Cypress::AppConfig['banner'],
        smtp_settings: Rails.application.config.action_mailer.smtp_settings,
        mode: application_mode,
        mode_settings: application_mode_settings,
        roles: %w(User ATL Admin None)
      }
    end

    def update
      update_application_mode params[:mode], params[:custom_options]
      update_banner params
      update_mailer_settings params
      redirect_to admin_path(anchor: 'application_settings')
    end

    private

    def update_banner(settings)
      Cypress::AppConfig['banner_message'] = settings['banner_message']
      Cypress::AppConfig['banner'] = settings['banner'] == '1'
    end

    def update_mailer_settings(settings)
      settings.each_pair do |key, val|
        key_str = key.to_s
        next unless key_str.include? 'mailer_'
        val = val == '' ? nil : val.to_i if key_str == 'mailer_port'
        env_config_key = key_str.sub('mailer_', '').to_sym
        Rails.application.config.action_mailer.smtp_settings[env_config_key] = val
      end
    end

    def update_application_mode(mode_name, options = {})
      if mode_name == 'internal'
        mode_internal
      elsif mode_name == 'demo'
        mode_demo
      elsif mode_name == 'atl'
        mode_atl
      elsif mode_name == 'custom'
        mode_custom options
      end
    end

    def valid_port?(port_str)
      true if (1..65_535).cover?(port_str.to_i)
    end
  end
end
