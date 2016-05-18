class AdminController < ApplicationController
  add_breadcrumb 'Admin', :admin_path
  before_action -> { raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.has_role? :admin }

  def show
    smtp_settings = Rails.application.config.action_mailer.smtp_settings
    @bundles = Bundle.all
    render locals: {
      banner_message: Settings.banner_message,
      address: smtp_settings.address,
      port: smtp_settings.port,
      domain: smtp_settings.domain,
      user_name: smtp_settings.user_name,
      password: smtp_settings.password,
      mode_settings: ApplicationController.helpers.application_mode_settings,
      mode: ApplicationController.helpers.application_mode,
      debug_features: Settings.enable_debug_features
    }
  end
end
