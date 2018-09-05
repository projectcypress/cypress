module Admin
  class SettingsController < AdminController
    def show
      redirect_to admin_path(anchor: 'application_settings')
    end

    def edit
      add_breadcrumb 'Edit Settings', :edit_settings_path
      render locals: Settings.locals_edit(application_mode_settings)
    end

    def update
      update_application_mode params[:mode], params[:custom_options]
      # Grab the parameters we are able to update directly and throw them to the settings model update method
      # update_settings = params.select { |key, _| key.match(/website|mailer|banner|message/) }
      Settings.current.update(update_settings)
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

    def update_settings
      params.permit(:banner_message, :warning_message, :mailer_address, :mailer_port, :mailer_domain, :mailer_user_name, :mailer_password)
    end
  end
end
