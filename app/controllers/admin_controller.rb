class AdminController < ApplicationController
  add_breadcrumb 'Admin', :admin_path
  before_action :require_admin

  def show
    @bundles = Bundle.all
    # dont allow them to muck with their own account
    @users = User.excludes(id: current_user.id).order_by(email:  1)
    @system_usage_stats = Vmstat.snapshot
    render locals: {
      banner_message: Settings.current.banner_message,
      warning_message: Settings.current.warning_message,
      banner: Settings.current.banner,
      default_url_options: Rails.application.config.action_mailer.default_url_options,
      smtp_settings: Rails.application.config.action_mailer.smtp_settings,
      mode: application_mode,
      mode_settings: application_mode_settings,
      debug_features: Settings.current.enable_debug_features,
      server_needs_restart: Settings.current.server_needs_restart
    }
  end

  def download_logs
    zip = Cypress::CreateDownloadZip.export_log_files.read
    send_data zip, type: 'application/zip', disposition: 'attachment', filename: "application_logs-#{Time.now.to_i}.zip"
  end

  def application_mode_settings
    settings_hash = { auto_approve: Settings.current.auto_approve, ignore_roles: Settings.current.ignore_roles,
                      debug_features: Settings.current.enable_debug_features }
    settings_hash[:default_role] = if Settings.current.default_role.nil? || Settings.current.default_role.empty?
                                     'None'
                                   elsif Settings.current.default_role == :atl
                                     'ATL'
                                   else
                                     Settings.current.default_role.to_s.humanize
                                   end
    settings_hash
  end

  def mode_internal
    Settings.current.update(auto_approve: true,
                            ignore_roles: true,
                            default_role: '',
                            enable_debug_features: true)
  end

  def mode_demo
    Settings.current.update(auto_approve: true,
                            ignore_roles: false,
                            default_role: 'user',
                            enable_debug_features: true)
  end

  def mode_atl
    Settings.current.update(auto_approve: false,
                            ignore_roles: false,
                            default_role: '',
                            enable_debug_features: false)
  end

  def mode_custom(settings)
    Settings.current.update(auto_approve: settings['auto_approve'] == 'enable',
                            ignore_roles: settings['ignore_roles'] == 'enable',
                            default_role: settings['default_role'] == 'None' ? '' : settings['default_role'].underscore.to_sym,
                            enable_debug_features: settings['debug_features'] == 'enable')
  end

  private

  def require_admin
    raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.user_role? :admin
  end
end
