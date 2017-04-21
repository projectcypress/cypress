module Admin
  class SettingsController < AdminController
    def show
      redirect_to admin_path(anchor: 'application_settings')
    end

    def edit
      add_breadcrumb 'Edit Settings', :edit_settings_path
      render locals: {
        banner_message: Settings.current.banner_message,
        warning_message: Settings.current.warning_message,
        banner: Settings.current.banner,
        smtp_settings: Rails.application.config.action_mailer.smtp_settings,
        mode: application_mode,
        mode_settings: application_mode_settings,
        roles: %w(User ATL Admin None)
      }
    end

    def update
      update_application_mode params[:mode], params[:custom_options]
      # Grab the parameters we are able to update directly and throw them to the settings model update method
      update_settings = params.select { |key, _| key.match(/mailer|banner|message/) }
      Settings.current.update(update_settings)
      Settings.apply_mailer_settings
      redirect_to admin_path(anchor: 'application_settings')
    end

    private

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
