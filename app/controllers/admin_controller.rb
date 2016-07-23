class AdminController < ApplicationController
  add_breadcrumb 'Admin', :admin_path
  before_action :require_admin

  def show
    @bundles = Bundle.all
    # dont allow them to muck with their own account
    @users = User.excludes(id: current_user.id).order_by(email:  1)
    render locals: {
      banner_message: Settings.banner_message,
      banner: Settings.banner,
      smtp_settings: Rails.application.config.action_mailer.smtp_settings,
      mode: ApplicationController.helpers.application_mode,
      mode_settings: ApplicationController.helpers.application_mode_settings,
      debug_features: Settings.enable_debug_features
    }
  end

  private

  def require_admin
    raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.user_role? :admin
  end
end
