class AdminController < ApplicationController
  add_breadcrumb 'Admin', :admin_path
  before_action :require_admin

  def show
    @bundles = Bundle.all
    # dont allow them to muck with their own account
    @users = User.excludes(id: current_user.id).order_by(email:  1)
    @system_usage_stats = Vmstat.snapshot
    render locals: {
      banner_message: Settings.banner_message,
      banner: Settings.banner,
      smtp_settings: Rails.application.config.action_mailer.smtp_settings,
      mode: application_mode,
      mode_settings: application_mode_settings,
      debug_features: Settings.enable_debug_features
    }
  end

  def download_logs
    zip = Cypress::CreateDownloadZip.export_log_files.read
    send_data zip, type: 'application/zip', disposition: 'attachment', filename: "application_logs-#{Time.now.to_i}.zip"
  end

  def application_mode_settings
    settings_hash = { auto_approve: Settings[:auto_approve], ignore_roles: Settings[:ignore_roles], debug_features: Settings[:enable_debug_features] }
    settings_hash[:default_role] = if Settings[:default_role].nil?
                                     'None'
                                   elsif Settings[:default_role] == :atl
                                     'ATL'
                                   else
                                     Settings[:default_role].to_s.humanize
                                   end
    settings_hash
  end

  def mode_internal
    Settings[:auto_approve] = true
    Settings[:ignore_roles] = true
    Settings[:default_role] = nil
    Settings[:enable_debug_features] = true
  end

  def mode_demo
    Settings[:auto_approve] = true
    Settings[:ignore_roles] = false
    Settings[:default_role] = :user
    Settings[:enable_debug_features] = true
  end

  def mode_atl
    Settings[:auto_approve] = false
    Settings[:ignore_roles] = false
    Settings[:default_role] = nil
    Settings[:enable_debug_features] = false
  end

  def mode_custom(settings)
    Settings[:auto_approve] = settings['auto_approve'] == 'enable'
    Settings[:ignore_roles] = settings['ignore_roles'] == 'enable'
    Settings[:default_role] = settings['default_role'] == 'None' ? nil : settings['default_role'].underscore.to_sym
    Settings[:enable_debug_features] = settings['debug_features'] == 'enable'
  end

  private

  def require_admin
    raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.user_role? :admin
  end
end
