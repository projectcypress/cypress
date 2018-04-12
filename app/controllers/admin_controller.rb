class AdminController < ApplicationController
  add_breadcrumb 'Admin', :admin_path
  before_action :require_admin

  def show
    @bundles = Bundle.order_by('deprecated asc').all
    # dont allow them to muck with their own account
    @users = User.excludes(id: current_user.id).order_by(email: 1)
    @system_usage_stats = Vmstat.snapshot
    locals_admin_show = Settings.locals_admin_show(application_mode_settings)
    render locals: { locals_admin_show: locals_admin_show, server_needs_restart: locals_admin_show.server_needs_restart }
  end

  def download_logs
    zip = Cypress::CreateDownloadZip.export_log_files.read
    send_data zip, type: 'application/zip', disposition: 'attachment', filename: "application_logs-#{Time.now.to_i}.zip"
  end

  def application_mode_settings
    Settings.admin_settings_hash
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
end
