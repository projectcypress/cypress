class AdminController < ApplicationController
  add_breadcrumb 'Admin', :admin_path
  before_action :require_admin

  def show
    @bundles = Bundle.all
    # dont allow them to muck with their own account
    @users = User.excludes(id: current_user.id).order_by(email:  1)
    @system_usage_stats = Vmstat.snapshot
    render locals: {
      banner_message: APP_CONFIG['banner_message'],
      banner: APP_CONFIG['banner'],
      smtp_settings: Rails.application.config.action_mailer.smtp_settings,
      mode: application_mode,
      mode_settings: application_mode_settings,
      debug_features: APP_CONFIG['enable_debug_features']
    }
  end

  def download_logs
    zip = Cypress::CreateDownloadZip.export_log_files.read
    send_data zip, type: 'application/zip', disposition: 'attachment', filename: "application_logs-#{Time.now.to_i}.zip"
  end

  def application_mode_settings
    settings_hash = { auto_approve: APP_CONFIG['auto_approve'], ignore_roles: APP_CONFIG['ignore_roles'],
                      debug_features: APP_CONFIG['enable_debug_features'] }
    settings_hash[:default_role] = if APP_CONFIG['default_role'].nil?
                                     'None'
                                   elsif APP_CONFIG['default_role'] == :atl
                                     'ATL'
                                   else
                                     APP_CONFIG['default_role'].to_s.humanize
                                   end
    settings_hash
  end

  def mode_internal
    APP_CONFIG['auto_approve'] = true
    APP_CONFIG['ignore_roles'] = true
    APP_CONFIG['default_role'] = nil
    APP_CONFIG['enable_debug_features'] = true
  end

  def mode_demo
    APP_CONFIG['auto_approve'] = true
    APP_CONFIG['ignore_roles'] = false
    APP_CONFIG['default_role'] = :user
    APP_CONFIG['enable_debug_features'] = true
  end

  def mode_atl
    APP_CONFIG['auto_approve'] = false
    APP_CONFIG['ignore_roles'] = false
    APP_CONFIG['default_role'] = nil
    APP_CONFIG['enable_debug_features'] = false
  end

  def mode_custom(settings)
    APP_CONFIG['auto_approve'] = settings['auto_approve'] == 'enable'
    APP_CONFIG['ignore_roles'] = settings['ignore_roles'] == 'enable'
    APP_CONFIG['default_role'] = settings['default_role'] == 'None' ? nil : settings['default_role'].underscore.to_sym
    APP_CONFIG['enable_debug_features'] = settings['debug_features'] == 'enable'
  end

  private

  def require_admin
    raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.user_role? :admin
  end
end
