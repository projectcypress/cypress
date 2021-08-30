# frozen_string_literal: true

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
      Settings.current.update(update_settings)
      redirect_to admin_path(anchor: 'application_settings')
    end

    private

    def update_application_mode(mode_name, options = {})
      case mode_name
      when 'internal'
        mode_internal
      when 'demo'
        mode_demo
      when 'atl'
        mode_atl
      when 'custom'
        mode_custom options
      end
    end

    def update_settings
      params.permit(:banner, :umls, :http_proxy, :website_domain, :website_port, :banner_message, :warning_message,
                    :mailer_address, :mailer_port, :mailer_domain, :mailer_user_name, :mailer_password, :api_documentation,
                    :api_documentation_path, :downloadable_bundles, :downloadable_bundles_path)
    end
  end
end
