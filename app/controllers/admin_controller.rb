class AdminController < ApplicationController
  add_breadcrumb 'Admin', :admin_path
  before_action -> { raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.has_role? :admin }

  def show
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
end
