class Settings
  include Mongoid::Document

  # If you are adding a new field, you should add a default value here, however
  # note that you will also need to add a migration in order to setup the field
  # to a sane default value for existing users! Migrations are run every time
  # the app is upgraded by the upgrade script, however they are not run for
  # users of the docker containers.

  field :default_bundle, type: String, default: '3.0.0'
  field :enable_logging, type: Boolean, default: false
  # set to true to enable a banner at the top of every page with the "banner_message" text from below
  field :banner, type: Boolean, default: false
  field :banner_message, type: String, default: APP_CONSTANTS['default_banner_message']
  field :warning_message, type: String, default: APP_CONSTANTS['default_warning_message']
  # ignore roles completely -- this is essentially the same as everyone in the system being an admin, default true
  field :ignore_roles, type: Boolean, default: (ENV['IGNORE_ROLES'].nil? ? true : ENV['IGNORE_ROLES'].to_boolean)
  # enable the "debug features" such as allowing QA testers to produce known good results for a task, default true
  field :enable_debug_features, type: Boolean, default: (ENV['ENABLE_DEBUG_FEATURES'].nil? ? true : ENV['ENABLE_DEBUG_FEATURES'].to_boolean)
  # the default role to assign to a user upon at creation -- this should be either admin, atl, user or empty string
  # a user without a role will not be able to create or view any vendors.  You may want to set this to ''
  # when an admin is required to approve new users and have the admin set the role there, default :user
  field :default_role, type: Symbol, default: (ENV['DEFAULT_ROLE'] || :user)
  field :auto_approve, type: Boolean, default: (ENV['AUTO_APPROVE'].nil? ? true : ENV['AUTO_APPROVE'].to_boolean)
  # sets whether or not Users are automatically linked to a Vendor based off the vendors points of contacts. Setting to true will
  # auto associate a User to a vendor when a user is created and a vendor point of contanct contains the same email address as the
  # user.  Likewise if a point of contact is added to a vendor and a User in the system has the same email address then the user
  # will be associated with the vendor.  The association is also automatically updated/rmoved when the user is removed from the system
  # or the point of contact is removed or updated from the vendor.  Setting this to true will also enable the devise plugin confirmable
  # which will require users to confirm their registration via an email link sent to their address.
  # Setting this to false disables the automatic associations as well as the devise confirmable pluggin
  field :auto_associate_pocs, type: Boolean, default: false
  field :auto_confirm, type: Boolean, default: true
  field :bundle_file_path, type: String, default: 'temp/bundles'
  field :file_upload_root, type: String, default: 'data/upload/'
  field :server_needs_restart, type: Boolean, default: false

  field :website_domain, type: String, default: (Rails.env.production? ? ENV['WEBSITE_DOMAIN'] : 'localhost')
  field :website_port, type: Integer, default: (Rails.env.production? ? (ENV['WEBSITE_PORT'] || 80) : 3000)
  field :mailer_address, type: String, default: (ENV['MAILER_ADDRESS'] || '')
  field :mailer_port, type: Integer, default: (ENV['MAILER_PORT'] || '')
  field :mailer_domain, type: String, default: (ENV['MAILER_DOMAIN'] || '')
  field :mailer_user_name, type: String, default: (ENV['MAILER_USER_NAME'] || '')
  field :mailer_password, type: String, default: (ENV['MAILER_PASSWORD'] || '')
  field :mailer_authentication, type: Symbol, default: 'plain'

  validate :instance_is_singleton

  after_update :sync_bundle, :check_server_restart
  after_save :clear_settings_cache
  before_destroy :clear_settings_cache

  # This model should only be called using this method
  def self.current
    return first if ENV['SKIP_SETTINGS_CREATE']&.to_boolean.eql?(true)

    Rails.cache.fetch('settings') do
      first_or_create
    end
  end

  def self.locals_edit(application_mode_settings)
    {
      banner_message: current.banner_message, warning_message: current.warning_message, mode: current.application_mode,
      banner: current.banner, default_url_options: current.fetch_url_settings,
      smtp_settings: current.fetch_smtp_settings, mode_settings: application_mode_settings, roles: %w[User ATL Admin None]
    }
  end

  def self.locals_admin_show(application_mode_settings)
    {
      banner_message: current.banner_message, warning_message: current.warning_message, mode: current.application_mode,
      banner: current.banner, default_url_options: Rails.application.config.action_mailer.default_url_options,
      smtp_settings: Rails.application.config.action_mailer.smtp_settings, mode_settings: application_mode_settings,
      debug_features: current.enable_debug_features, server_needs_restart: current.server_needs_restart
    }
  end

  def self.admin_settings_hash
    settings_hash = { auto_approve: current.auto_approve, ignore_roles: current.ignore_roles,
                      debug_features: current.enable_debug_features }
    settings_hash[:default_role] = if current.default_role.blank?
                                     'None'
                                   elsif current.default_role == :atl
                                     'ATL'
                                   else
                                     current.default_role.to_s.humanize
                                   end
    settings_hash
  end

  # This will only work if run from an initializer on startup. If run during regular app operation the settings will
  # only be applied to one thread.
  def apply_mailer_settings
    ActionMailer::Base.default_url_options = Cypress::Application.config.action_mailer.default_url_options = fetch_url_settings
    ActionMailer::Base.smtp_settings = Cypress::Application.config.action_mailer.smtp_settings = fetch_smtp_settings

    # Clear server restart required warning
    update(server_needs_restart: false)

    true
  end

  def fetch_smtp_settings
    {
      address: mailer_address,
      port: mailer_port,
      domain: mailer_domain,
      user_name: mailer_user_name,
      password: mailer_password,
      authentication: mailer_authentication,
      enable_starttls_auto: true
    }
  end

  def fetch_url_settings
    {
      host: website_domain,
      port: website_port
    }
  end

  def application_mode
    return 'Internal' if mode_internal?
    return 'Demo' if mode_demo?
    return 'ATL' if mode_atl?

    'Custom'
  end

  def mode_internal?
    auto_approve && ignore_roles && enable_debug_features && default_role.blank?
  end

  def mode_demo?
    auto_approve && !ignore_roles && enable_debug_features && default_role == :user
  end

  def mode_atl?
    !auto_approve && !ignore_roles && !enable_debug_features && default_role.blank?
  end

  private

  def sync_bundle
    if default_bundle_changed?
      # sync default bundle with settings
      Bundle.each do |bundle|
        bundle.active = bundle.version == default_bundle
        bundle.save!
      end
    end
  end

  # Check to see if mailer settings have been changed, since they require a server restart
  def check_server_restart
    set(server_needs_restart: true) if changed.any? { |field| /mailer|website/ =~ field }
  end

  def clear_settings_cache
    Rails.cache.delete('settings')
  end

  def instance_is_singleton
    singleton = Settings.first
    errors.add(:base, 'Only one settings instance is allowed') if singleton != self && !singleton.nil?
  end
end
