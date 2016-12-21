class AdminController < ApplicationController
  add_breadcrumb 'Admin', :admin_path
  before_action :require_admin

  def show
    @bundles = Bundle.all
    # dont allow them to muck with their own account
    @users = User.excludes(id: current_user.id).order_by(email:  1)
    @system_usage_stats = Vmstat.snapshot
    render locals: {
      banner_message: Cypress::AppConfig['banner_message'],
      banner: Cypress::AppConfig['banner'],
      smtp_settings: Rails.application.config.action_mailer.smtp_settings,
      mode: application_mode,
      mode_settings: application_mode_settings,
      debug_features: Cypress::AppConfig['enable_debug_features']
    }
  end

  def download_logs
    zip = Cypress::CreateDownloadZip.export_log_files.read
    send_data zip, type: 'application/zip', disposition: 'attachment', filename: "application_logs-#{Time.now.to_i}.zip"
  end

  def application_mode_settings
    settings_hash = { auto_approve: Cypress::AppConfig['auto_approve'], ignore_roles: Cypress::AppConfig['ignore_roles'],
                      debug_features: Cypress::AppConfig['enable_debug_features'] }
    settings_hash[:default_role] = if Cypress::AppConfig['default_role'].nil?
                                     'None'
                                   elsif Cypress::AppConfig['default_role'] == :atl
                                     'ATL'
                                   else
                                     Cypress::AppConfig['default_role'].to_s.humanize
                                   end
    settings_hash
  end

  def mode_internal
    Cypress::AppConfig['auto_approve'] = true
    Cypress::AppConfig['ignore_roles'] = true
    Cypress::AppConfig['default_role'] = nil
    Cypress::AppConfig['enable_debug_features'] = true
  end

  def mode_demo
    Cypress::AppConfig['auto_approve'] = true
    Cypress::AppConfig['ignore_roles'] = false
    Cypress::AppConfig['default_role'] = :user
    Cypress::AppConfig['enable_debug_features'] = true
  end

  def mode_atl
    Cypress::AppConfig['auto_approve'] = false
    Cypress::AppConfig['ignore_roles'] = false
    Cypress::AppConfig['default_role'] = nil
    Cypress::AppConfig['enable_debug_features'] = false
  end

  def mode_custom(settings)
    Cypress::AppConfig['auto_approve'] = settings['auto_approve'] == 'enable'
    Cypress::AppConfig['ignore_roles'] = settings['ignore_roles'] == 'enable'
    Cypress::AppConfig['default_role'] = settings['default_role'] == 'None' ? nil : settings['default_role'].underscore.to_sym
    Cypress::AppConfig['enable_debug_features'] = settings['debug_features'] == 'enable'
  end

  private

  def require_admin
    raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.user_role? :admin
  end
end
